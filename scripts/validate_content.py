#!/usr/bin/env python3
"""Valida o conteúdo offline do app Swing Brasília antes de enviar para CI/App Store."""
import json
import re
import plistlib
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).parents[1]
CATALOG_PATH = ROOT / "iosApp/Resources/Catalog/venues.json"
IMAGES_PATH = ROOT / "iosApp/Resources/Images"
APPICON_PATH = ROOT / "iosApp/Resources/Assets.xcassets/AppIcon.appiconset"
INFOPLIST_PATH = ROOT / "iosApp/Info.plist"
PRIVACY_PATH = ROOT / "iosApp/Resources/PrivacyInfo.xcprivacy"
CREDITS_PATH = ROOT / "docs/content/image-credits.json"

CATEGORIES = {"Casa liberal", "Motel e suíte", "Sex shop e boutique"}
THEMES = {"red", "ivory"}
SLUG_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")

REQUIRED_FIELDS = {
    "slug", "name", "region", "area", "category", "summary", "coordinates",
    "theme", "status", "updatedAt", "sourceLabel", "sourceUrl",
    "newcomerFriendly", "gallery", "editorialSignals", "notes",
}
OPTIONAL_FIELDS = {"logo", "featured", "isSponsored", "sponsorLabel"}


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def require_text(value, label):
    require(isinstance(value, str) and value.strip() and value.strip() == value, f"{label} deve ser texto não vazio e sem espaços externos")


def load_catalog():
    require(CATALOG_PATH.is_file(), f"Catálogo ausente: {CATALOG_PATH}")
    try:
        data = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise AssertionError(f"JSON inválido: {error}") from error
    require(isinstance(data, dict), "A raiz deve ser um objeto")
    require(data.get("version") == 1, "A raiz deve ter version 1")
    require(isinstance(data.get("venues"), list) and data["venues"], "venues deve ser uma lista não vazia")
    return data["venues"]


def validate_venue(venue, index, image_files):
    label = f"venues[{index}]"
    require(isinstance(venue, dict), f"{label} deve ser um objeto")
    missing = REQUIRED_FIELDS - venue.keys()
    unknown = venue.keys() - REQUIRED_FIELDS - OPTIONAL_FIELDS
    require(not missing, f"{label} não contém: {sorted(missing)}")
    require(not unknown, f"{label} contém campos desconhecidos: {sorted(unknown)}")

    for field in ("slug", "name", "region", "area", "summary", "status", "updatedAt", "sourceLabel", "sourceUrl"):
        require_text(venue[field], f"{label}.{field}")
    parsed_source = urlparse(venue["sourceUrl"])
    require(parsed_source.scheme in {"http", "https"} and parsed_source.netloc, f"{label}.sourceUrl inválida")
    require(not (parsed_source.netloc == "www.google.com" and parsed_source.path == "/search"), f"{label}.sourceUrl deve ser uma fonte oficial, não uma busca do Google")

    require(SLUG_PATTERN.fullmatch(venue["slug"]), f"{label}.slug deve ser um slug ASCII")
    require(venue["category"] in CATEGORIES, f"{label}.category inválida: {venue['category']!r}")
    require(venue["theme"] in THEMES, f"{label}.theme inválido: {venue['theme']!r}")
    require(isinstance(venue["newcomerFriendly"], bool), f"{label}.newcomerFriendly deve ser booleano")

    coord = venue["coordinates"]
    require(isinstance(coord, dict) and set(coord) == {"latitude", "longitude"}, f"{label}.coordinates deve conter latitude e longitude")
    require(isinstance(coord["latitude"], (int, float)) and isinstance(coord["longitude"], (int, float)), f"{label}.coordinates devem ser numéricas")
    require(-90 <= coord["latitude"] <= 90 and -180 <= coord["longitude"] <= 180, f"{label}.coordinates fora dos limites")

    require(isinstance(venue["gallery"], list) and venue["gallery"], f"{label}.gallery deve ser uma lista não vazia")
    require(isinstance(venue["editorialSignals"], list) and venue["editorialSignals"], f"{label}.editorialSignals deve ser uma lista não vazia")
    require(isinstance(venue["notes"], list) and venue["notes"], f"{label}.notes deve ser uma lista não vazia")

    referenced = list(venue["gallery"])
    if venue.get("logo"):
        referenced.append(venue["logo"])
    for filename in referenced:
        require(Path(filename).name == filename, f"{label} referencia caminho inválido: {filename!r}")
        require(filename in image_files, f"{label} referencia imagem inexistente: {filename}")

    if venue.get("isSponsored"):
        require(venue.get("sponsorLabel"), f"{label}: patrocinado sem sponsorLabel")


def validate_images():
    require(IMAGES_PATH.is_dir(), f"Diretório de imagens ausente: {IMAGES_PATH}")
    return {path.name for path in IMAGES_PATH.iterdir() if path.is_file()}


def validate_credits():
    require(CREDITS_PATH.is_file(), f"Créditos de imagens ausentes: {CREDITS_PATH}")
    credits = json.loads(CREDITS_PATH.read_text(encoding="utf-8"))
    require(credits.get("status") == "approved", "Créditos de imagens ainda não foram aprovados")
    for item in credits.get("items", []):
        image_id = item.get("id", "<sem id>")
        require(item.get("author"), f"Autor ausente para a imagem {image_id}")
        require(item.get("source"), f"Fonte ausente para a imagem {image_id}")
        require(item.get("license"), f"Licença ausente para a imagem {image_id}")
        require(item.get("reviewStatus") == "approved", f"Imagem não aprovada: {image_id}")


def validate_app_icon():
    require(APPICON_PATH.is_dir(), f"AppIcon ausente: {APPICON_PATH}")
    for size in (1024, 180, 120):
        require((APPICON_PATH / f"AppIcon-{size}.png").is_file(), f"AppIcon-{size}.png ausente")


def validate_plists():
    require(INFOPLIST_PATH.is_file(), f"Info.plist ausente: {INFOPLIST_PATH}")
    with open(INFOPLIST_PATH, "rb") as file:
        plistlib.load(file)

    require(PRIVACY_PATH.is_file(), f"PrivacyInfo.xcprivacy ausente: {PRIVACY_PATH}")
    with open(PRIVACY_PATH, "rb") as file:
        privacy = plistlib.load(file)
    require(privacy.get("NSPrivacyTracking") is False, "NSPrivacyTracking deve ser false")
    require(privacy.get("NSPrivacyCollectedDataTypes") == [], "Não deve haver dados coletados")


def main():
    venues = load_catalog()
    image_files = validate_images()
    validate_credits()
    validate_app_icon()
    validate_plists()

    seen_slugs = set()
    seen_names = set()
    for index, venue in enumerate(venues):
        validate_venue(venue, index, image_files)
        require(venue["slug"] not in seen_slugs, f"Slug duplicado: {venue['slug']}")
        require(venue["name"].casefold() not in seen_names, f"Nome duplicado: {venue['name']}")
        seen_slugs.add(venue["slug"])
        seen_names.add(venue["name"].casefold())

    houses = sum(1 for v in venues if v["category"] == "Casa liberal")
    motels = sum(1 for v in venues if v["category"] == "Motel e suíte")
    shops = sum(1 for v in venues if v["category"] == "Sex shop e boutique")
    sponsored = sum(1 for v in venues if v.get("isSponsored"))
    print(f"Conteúdo válido: {len(venues)} locais ({houses} casas, {motels} motéis, {shops} sex shops), {sponsored} patrocinado(s), {len(image_files)} imagens")
    print("Todos os checks passaram.")


if __name__ == "__main__":
    main()
