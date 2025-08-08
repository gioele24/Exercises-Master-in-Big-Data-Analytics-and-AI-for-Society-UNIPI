# Given the input CSV file 'lego_sets.csv', extract all records that match these conditions:
# - Lego sets included in date [2000, 2010]
# - Number of pieces in the set >= 70
# Write the output to three different files: a JSON file, a JSONL file, and an XML file.

import csv
import json
from bs4 import BeautifulSoup

def filter_records(input_file, xml_output_file, json_output_file, start_year, end_year, min_pieces):
    """
    Filter records from a CSV file and write them to both XML and JSON files.
    """
    selected_records = []

    # Read and filter records from the CSV file
    with open(input_file, 'r', encoding="utf-8-sig") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            try:
                year = int(row["year"])
                pieces = float(row["pieces"]) if row["pieces"] else 0
            except ValueError:
                continue

            if start_year <= year <= end_year and pieces > min_pieces:
                selected_records.append(row)


    # Write records to an XML file
    soup = BeautifulSoup('<dataset></dataset>', 'xml')
    root = soup.find("dataset")
    for record in selected_records:
        item = soup.new_tag('record')
        for key, value in record.items():
            tag = soup.new_tag(key)
            tag.string = value
            item.append(tag)
        root.append(item)

    # Write records into an XML file.
    with open(xml_output_file, 'w') as file:
        file.write(soup.prettify())

    # Write records into a JSON file
    with open(json_output_file, 'w') as file:
        json.dump(selected_records, file, indent=4)

   # Write records into a JSONL file.
    with open(json_output_file+"l", 'w') as file:
        for r in selected_records:
            file.write(json.dumps(r)+"\n")

if __name__ == "__main__":
    # Example usage
    filter_records('lego_sets.csv', 'filtered_converted.xml', 'filtered_converted.json', 2000, 2010, 70)
