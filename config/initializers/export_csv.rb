#coding: utf-8
#为Array类添加导出csv方法
require "nkf"
class Array
  BOM_HEADER ="FFFE".gsub(/\s/,'').to_a.pack("H*")
  def to_csv(options = {})
    return '' if self.empty?

    klass      = self.first.class
    attributes = self.first.attributes.keys.sort.map(&:to_sym)

    if options[:only]
      columns = Array(options[:only]) & attributes
    else
      columns = attributes - Array(options[:except])
    end

    columns += Array(options[:methods])

    return '' if columns.empty?

    output = FasterCSV.generate(:col_sep => "\t", :row_sep => "\r\n") do |csv|
      csv << ["序号"] + columns.map { |column| klass.human_attribute_name(column) } unless options[:headers] == false
      self.each_with_index do |item,index|
        csv << [index + 1] + columns.collect { |column| item.send(column) }
      end
    end
    output
  end
  def export_csv(options ={},with_bom_header = true)
    #参考http://blog.enjoyrails.com/2008/12/12/rails-导入导出csv数据时的中文编码问题/
    #BOM头信息
    ret = ""
    if with_bom_header
      #ret = NKF.nkf("--oc UTF-16LE-BOM",self.to_csv(options))
      ret = BOM_HEADER + self.to_csv(options).utf8_to_utf16
    else
      ret = self.to_csv(options).utf8_to_utf16
    end
    ret
  end
  #将数组中的数据导出为一行
  def export_line_csv(with_bom_header = false)
    output = FasterCSV.generate(:col_sep => "\t", :row_sep => "\r\n")do |csv|
      csv << self
    end
    if with_bom_header
      ret = BOM_HEADER + output.utf8_to_utf16
      #ret = NKF.nkf("--oc UTF-16LE-BOM",output)
    else
      ret = output.utf8_to_utf16
      #ret = NKF.nkf("--oc UTF-16LE-BOM",output)
    end
    ret
  end
end
#为active_record 添加导入导出方法
module ActiveRecord
  class Base
    def self.export2csv(dir=Rails.root.join('db/export'))
      require 'fastercsv'
      records = self.find(:all)
      csv_string = FasterCSV.generate() do |csv|
        records.each do |r|
          attr = r.attributes.delete_if { |key,value| self.primary_key == key }
          csv << ([r.id]  + attr.keys.sort.collect {|key| r[key]})
        end
      end
      file_name = File.join(dir,"#{self.table_name}.csv")
      File.delete(file_name) if File.exist? file_name
      File.open(file_name,"w") do |file|
        file.syswrite csv_string
      end
    end
    #导入数据到数据表中,包括id
    def self.import_csv(dir=Rails.root.join('db/export'))
      require 'fastercsv'
      self.destroy_all
      file_name = File.join(dir,"#{self.table_name}.csv")
      rows = FasterCSV::read(file_name)
      rows.each do |row|
        m = self.new
        #给各个字段赋值
        col_index = 0

        attr = m.attributes.delete_if { |key,value| self.primary_key == key }

        (attr.keys.sort).each do |attr|
          col_index = col_index + 1
          m.send("#{attr}=",row[col_index])
        end
        m.id = row[0]
        m.save
      end
    end
  end
end
