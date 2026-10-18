"""Export only the Workshop preview; preserve the owner-supplied mod artwork."""
import hashlib
from io import BytesIO
import json
from pathlib import Path

from PIL import Image, __version__ as pillow_version

ROOT = Path(__file__).resolve().parents[1]
SOURCE = "Contents/mods/B47ANCEDHarvest/thumbnail.png"
# Steam upload constraint, not a gameplay setting. Stay below decimal 1 MB.
MAX_BYTES = 1_000_000


def main():
    metadata_path = ROOT / "docs/ARTWORK.json"
    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    source_bytes = (ROOT / SOURCE).read_bytes()
    assert hashlib.sha256(source_bytes).hexdigest() == metadata["sha256"]
    with Image.open(BytesIO(source_bytes)) as source:
        source.load()
        assert source.size == (metadata["width"], metadata["height"])
        for edge in (1024, 960, 896, 832, 768, 512):
            image = source.copy()
            image.thumbnail((edge, edge), Image.Resampling.LANCZOS)
            stream = BytesIO()
            image.save(stream, format="PNG", optimize=True, compress_level=9)
            data = stream.getvalue()
            if len(data) < MAX_BYTES:
                break
        else:
            raise SystemExit("No preview export fits Steam's size limit; nothing written")
    with Image.open(BytesIO(data)) as exported:
        exported.verify()
    assert (ROOT / SOURCE).read_bytes() == source_bytes
    (ROOT / "preview.png").write_bytes(data)
    metadata["provenance"] = "Owner-supplied PNG retained unchanged in the mod thumbnail; a smaller Workshop PNG export was explicitly approved."
    metadata["applied_files"] = [SOURCE]
    metadata["workshop_export"] = {
        "path": "preview.png", "source": SOURCE,
        "sha256": hashlib.sha256(data).hexdigest(),
        "width": image.width, "height": image.height, "bytes": len(data),
        "max_bytes_exclusive": MAX_BYTES,
        "method": "Pillow thumbnail LANCZOS; optimized PNG compression level 9",
        "pillow_version": pillow_version,
    }
    metadata_path.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(json.dumps(metadata["workshop_export"], indent=2))


if __name__ == "__main__":
    main()
