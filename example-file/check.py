import yaml

with open("ex.yml", 'r', encoding="utf-8") as f:
    try:
        print(yaml.safe_load(f))
    except Exception:
        print("PARSE ERROR")
