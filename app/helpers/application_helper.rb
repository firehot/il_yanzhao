# -*- encoding : utf-8 -*-
#coding: utf-8
module ApplicationHelper
  #排序辅助方法
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current_sort_column #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "desc") ? "asc" : "desc"
    link_to title, params.merge(:sort => column, :direction => direction,:page => nil), {:class => css_class,:title => "点击可排序"}
  end
  #金额转中文大写
  def convertNumToChinese(num)
    chineseNumArr=['零','壹','贰','叁','肆','伍','陆','柒','捌','玖']
    chinesePosArr=['万','仟','佰','拾','亿','仟','佰','拾','万','仟','佰','拾','元','角','分']
    chineseNum=''
    chinesePos=''
    strChinese=''
    nzero=0
    strNum=(num*100).abs.to_i.to_s
    i=0
    length=strNum.length
    posValue=0
    pos=chinesePosArr.length-length
    while i<length
      posValue=strNum[i].chr.to_i

      if(i!=(length-3) && i!=(length-7) && i!=(length-11) && i!=(length-15))
        if(posValue==0)
          chineseNum=''
          chinesePos=''
          nzero+=1
        else
          if(nzero!=0)
            chineseNum=chineseNumArr[0]+chineseNumArr[posValue]
            chinesePos=chinesePosArr[pos+i]
            nzero=0
          else
            chineseNum=chineseNumArr[posValue]
            chinesePos=chinesePosArr[pos+i]
            nzero=0
          end
        end
      else
        if(posValue!=0 && nzero!=0)
          chineseNum=chineseNumArr[0]+chineseNumArr[posValue]
          chinesePos=chinesePosArr[pos+i]
          nzero=0
        else
          if(posValue!=0 && nzero==0)
            chineseNum=chineseNumArr[posValue]
            chinesePos=chinesePosArr[pos+i]
            nzero=0
          else
            if(length>=11)
              chineseNum=''
              nzero+=1
            else
              chineseNum=''
              chinesePos=chinesePosArr[pos+i]
              nzero+=1
            end
          end
        end
      end
      if(i==(length-11) || i==(length-3))
        chinesePos=chinesePosArr[pos+i]
      end
      strChinese=strChinese+chineseNum+chinesePos
      if(i==(length-1) && posValue==0)
        strChinese=strChinese+'整'
      end
      i+=1
    end
    strChinese ='负' + strChinese if num < 0
    strChinese
  end
  #根据索引生成页面上的序号
  def order_no(index,cur_page = 1,rows_per_page = 30)
    cur_page = 1 if cur_page.blank?
    rows_per_page = 30 if rows_per_page.blank?
    cur_page = cur_page.to_i if cur_page.kind_of?(String)
    rows_per_page = cur_page.to_i if rows_per_page.kind_of?(String)
    index+1 + rows_per_page*(cur_page - 1)
  end
  #将foreign_key 生成association
  def foreign_key_to_association(column)
    ret = column.to_s.gsub!(/_id/,"")
    ret = column if ret.blank?
    ret.to_sym
  end
  #生成前后12个月的select
  def months_for_select
    ret = []
    (1..12).each do |step|
      mth = step.months.ago
      ret << [mth.strftime('%Y年%m月'),mth.strftime('%Y%m')]
    end
    ret
  end


end

