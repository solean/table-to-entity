
def parseOracleDescribe(file_name)
  f = File.open(file_name)
  lines = []
  columnInfo = []
  nullIndex = nil
  typeIndex = nil

  f.each.with_index do |line, i|
    if i == 0
      nullIndex = line.index('Null')
      typeIndex = line.index('Type')
    elsif i == 1
    else
      lines.push(line)
    end
  end

  lines.each do |line|
    notNull = line.index('NOT NULL') != nil
    name = nil
    if notNull
      name = line[0, nullIndex].strip()
    else
      name = line[0, typeIndex].strip()
    end
    type = line[typeIndex..-1].strip()
    columnInfo.push({
      'name' => name,
      'type' => type,
      'notNull' => notNull
    })
  end

  f.close()
  columnInfo
end

def camelify(str)
  return str if !str || !str.length
  str = str.downcase
  camelCase = ''
  i = 0
  charArr = str.split('')
  while i < charArr.length do
    ch = charArr[i]
    if ch == '_'
      camelCase += charArr[i + 1].upcase
      i+=2
    else
      camelCase += ch
      i+=1
    end
  end

  camelCase
end

def buildGetterAndSetter(name, type)
  camelCased = camelify(name)
  str = "\t@Column(name = \"#{name}\")\n"
  str += "\tpublic #{type} #{camelify('get_' + name)}() {\n\t\treturn #{camelCased};\n\t}\n\n"
  str += "\tpublic void #{camelify('set_' + name)}(#{type} #{camelCased}) {\n\t\tthis.#{camelCased} = #{camelCased};\n\t}\n\n"
end

def buildEntity(entityName, columns)
  varcharRegex = /^VARCHAR2\((?<numChars>[0-9]+)\)/
  numberRegex = /^NUMBER(\((?<numDigits>[0-9]+)\))?/
  dateRegex = /^DATE/

  entityStr = "\n\npublic class #{entityName} {\n"
  variables = ''
  gettersAndSetters = ''

  columns.each do |col|
    name = col['name']
    camelCased = camelify(name)

    case col['type']
    when varcharRegex
      variables += "\tprivate String #{camelCased};\n"
      gettersAndSetters += buildGetterAndSetter(name, 'String')
    when numberRegex
      variables += "\tprivate Long #{camelCased};\n"
      gettersAndSetters += buildGetterAndSetter(name, 'Long')
    when dateRegex
      variables += "\tprivate Date #{camelCased};\n"
      gettersAndSetters += buildGetterAndSetter(name, 'Date')
    end
  end

  entityStr += "#{variables}\n\n#{gettersAndSetters}}"
end


oracleDescribeFile = ARGV[0]
entityName = ARGV[1]
columns = parseOracleDescribe(oracleDescribeFile)
entity = buildEntity(entityName, columns)
File.open("#{entityName}.java", 'w') do |file|
  file.write(entity)
end
