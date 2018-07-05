# TODO properly scope bibs. not suppressed. print. etc.
#   currently limited to unsuppressed bibs (with items)

# TODO do we need to abort instead of writing anything?
#   currently only excludes withdrawn/suppressed item recs

# TODO files need to be broken up into <64 MB if this is also the way
#   we'll do full catalog extracts



# Find bibs in scope
# Write one marcxml record for each item record:
#   skip items that are withdrawn/suppressed

require_relative 'google_record'

conn = SierraDB

responsive_bib_query = <<-SQL
  select 'b' || rm.record_num || 'a' as bnum
  from sierra_view.bib_record b
  inner join sierra_view.record_metadata rm on rm.id = b.id
  where b.bcode3 not in ('n', 'd', 'c')
  limit 100
SQL

# random sample query
# responsive_bib_query = <<-SQL
#   select 'b' || rm.record_num || 'a' as bnum
#   from sierra_view.bib_record b
#   inner join sierra_view.record_metadata rm on rm.id = b.id
#   where b.bcode3 not in ('n', 'd', 'c')
#   and b.bcode2 = 'a'
#   order by random()
#   limit 100
# SQL

conn.make_query(responsive_bib_query)
conn.write_results('responsive_bibs.txt', include_headers: false)

err_log = File.open('output_errors.txt', 'w')
File.open('google_marc.xml',"w:UTF-8") do |xml_out|
  xml_out << MARC::XML_HEADER
  File.foreach('responsive_bibs.txt') do |bnum|
    bib = SierraBib.new(bnum.rstrip)
    next unless bib.items
    bib.items.each do |item|
      google = GoogleRecord.new(bib, item)
      # write xml or write warnings
      unless google.manual_write_xml(outfile: xml_out,
                                     strict: true)
        google.warnings.each do |warning|
          err_log << "#{google.bnum}\t#{google.inum}\t#{warning}\n"
        end
      end
    end
  end
  xml_out << MARC::XML_FOOTER
end
err_log.close