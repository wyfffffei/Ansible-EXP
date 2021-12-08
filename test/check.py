import yaml

file = open("x.yml", 'r', encoding="utf-8")

try:
    print(yaml.safe_load(file))
except Exception:
    print("E: PARSE ERROR")

file.close()
