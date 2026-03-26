---
name: pdf-form-filling
description: Fill PDF forms using a two-path workflow: direct field fill for real forms, calibrated text overlay for flat or broken PDFs.
---

# PDF Form Filling Procedure

Use this procedure whenever you are tasked with filling a PDF form.

Prefer the structured approach below over ad hoc editing.

## Dependencies

Required Python packages:

```bash
python3 -m pip install --user pymupdf pypdf
```

## Step 1 - Detect form type

```python
from pypdf import PdfReader

def has_form_fields(path):
    return bool(PdfReader(path).get_fields())
```

- If the PDF has form fields, use **Path A**
- If the PDF is flat or field filling renders badly, use **Path B**

## Path A - Fillable PDF

Use `pypdf` to fill form fields directly.

```python
from pypdf import PdfReader, PdfWriter

def fill_form_fields(input_path, output_path, field_data):
    reader = PdfReader(input_path)
    writer = PdfWriter()
    writer.append(reader)
    for page in writer.pages:
        writer.update_page_form_field_values(page, field_data)
    with open(output_path, "wb") as f:
        writer.write(f)
```

To discover field names:

```python
fields = PdfReader(path).get_fields()
for name, field in fields.items():
    print(name, field.get("/FT"), field.get("/V"))
```

If Path A creates artifacts like dropdown glyphs, broken checkboxes, or garbled text, abandon it and switch to **Path B**.

## Path B - Calibration Overlay

Use `PyMuPDF` to place text by coordinates.

Always run a calibration pass before final fill.

### Extract text spans

```python
import fitz

def get_all_spans(pdf_path, page_num=0):
    doc = fitz.open(pdf_path)
    spans = []
    for block in doc[page_num].get_text("dict")["blocks"]:
        if block["type"] == 0:
            for line in block["lines"]:
                for span in line["spans"]:
                    text = span["text"].strip()
                    if text:
                        spans.append((text, span["bbox"]))
    return spans
```

### Compute positions from labels

```python
def find_label(spans, text, near_y=None):
    matches = [(t, b) for t, b in spans if t == text]
    if not matches:
        return None
    if near_y is None:
        return matches[0][1]
    return min(matches, key=lambda m: abs((m[1][1] + m[1][3]) / 2 - near_y))[1]

def pos(spans, label_text, near_y=None):
    bbox = find_label(spans, label_text, near_y)
    if not bbox:
        return (0, 0)
    x = round(bbox[2] + 5, 1)
    y = round(bbox[3] - 1, 1)
    return (x, y)
```

Rules:

- `x` = label right edge + 5 px
- `y` = label bottom edge - 1 px
- for repeated labels, use `near_y` anchored to the correct row

### Build entries

```python
entries = [
    (*pos(spans, "Customer Name:"), "Acme Corp", 10),
    (*pos(spans, "Phone:"), "555-123-4567", 10),
    (*pos(spans, "Email:"), "info@acme.com", 10),
]
```

Format:

```text
(x, y, text, font_size)
```

### Calibration pass

```python
def calibration_pass(input_path, output_path, entries, radius=6):
    doc = fitz.open(input_path)
    page = doc[0]
    for i, (x, y, label, _) in enumerate(entries):
        page.draw_circle((x, y), radius, color=(1, 0, 0), fill=(1, 0.3, 0.3), width=1)
        page.insert_text((x + radius + 2, y + 4), f"{i + 1}:{label[:12]}", fontsize=6, color=(1, 0, 0))
    doc.save(output_path)
```

Review the calibration PDF and confirm:

- each dot is on the correct line
- each dot is to the right of its label
- no dot overlaps label text or lands on the wrong row

If calibration is wrong, adjust `near_y` or small x/y offsets and rerun.

### Final fill

```python
def overlay_text(input_path, output_path, entries):
    doc = fitz.open(input_path)
    page = doc[0]
    for x, y, text, font_size in entries:
        if text:
            page.insert_text((x, y), text, fontsize=font_size, color=(0, 0, 0))
    doc.save(output_path)
```

## Page 2 and beyond

For additional pages, use the same span-detection approach on `doc[1]`, `doc[2]`, and so on.

## Decision Rules

| Situation | Action |
|---|---|
| Fillable PDF, text fields only | Path A |
| Fillable PDF with artifacts | Path B |
| Flat PDF | Path B |
| Multiple fields with same label | Use `near_y` |
| Long text overflows | Reduce `font_size` to 8-9 or truncate |
| Calibration dot lands on label text | Increase x offset |
| Calibration dot lands on wrong row | Adjust `near_y` |
| Bad pre-existing overlay text | White-rect the area and re-overlay |

## Operating Guidance

- Save intermediate calibration outputs before final fill.
- Keep generated files inside the workspace or another allowed writable directory.
- Never overwrite the original input PDF without keeping a copy.
- If the PDF is ambiguous, explain which path you chose and why.
