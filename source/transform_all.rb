Dir.glob("*.xml") {|filename_with_extension|
  puts "Converting #{filename_with_extension}"
  filename = filename_with_extension.split(".")[0]
  `java -jar saxon9he.jar -xsl:transform.xsl -s:#{filename}.xml > ../chapters/#{filename}.tex`
}

