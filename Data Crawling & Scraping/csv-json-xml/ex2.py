# Given the input file 'lego_sets.xml' in XML format, extract all records that match these conditions:
# - Lego set including 'station' in its name
# - Theme is "Duplo"
# Write the output to another XML file.


from bs4 import BeautifulSoup

def filter_xml_records(input_file, output_file, product_subname, theme_name):

    # Open input file
    with open(input_file, 'r') as infile:
        # Parse input file with BS.
        soup = BeautifulSoup(infile, 'xml')

        # Create an empty BS object.
        filtered_records = BeautifulSoup(features='xml')

        # Create a new tag (our new root tag)
        ds = filtered_records.new_tag("dataset")
        # and add it to the newly created BS object.
        filtered_records.append(ds)

        # Find all records in the input XML file
        records = soup.find_all('record')

        # Iterate over records...
        for record in records:
            name = record.find('name').text
            # Apply defined filters.
            if not product_subname.lower() in name.lower():
                continue
            if not record.find('theme').text.lower() == theme_name.lower():
                continue

            # If here, the record is valid.
            ds.append(record)



        # Write the filtered records to a new XML file
        with open(output_file, 'w') as outfile:
            outfile.write(filtered_records.prettify())

if __name__ == "__main__":
    filter_xml_records('lego_sets.xml', 'lego_sets_filtered.xml', "station", "Duplo")
