class Reporter

  #def self.report(total_results)
  #  best_profit = []
  #  profit = []
  #  puts ""
  #  total_results.keys.each do |day|
  #    profit << total_results[day].select {|rs| rs[:net] > 0}

  #    result = total_results[day]

  #    puts "#################"
  #    puts "Resultado do dia #{day}"
  #    puts ""

  #    puts "- 3 piores resultados"
  #    result.first(3).each do |rs|
  #      puts "Net: #{rs[:net]} - Poss #{rs[:poss]}"
  #    end

  #    puts ""

  #    puts "- 3 melhores resultados"
  #    result.last(3).each do |rs|
  #      puts "Net: #{rs[:net]} - Poss #{rs[:poss]}"
  #    end
  #    puts ""
  #  end

  #  #possibilities.each do |poss|
  #  #  inter = true
  #  #  profit.each do |pro|
  #  #    match = pro.find {|net| net[:poss] == poss}
  #  #
  #  #    if match.nil? || match.empty?
  #  #      inter = false;
  #  #    end
  #  #  end
  #  #  if inter
  #  #    best_profit << poss
  #  #  end
  #  #end
  #  #
  #  #puts ""
  #  #puts "#################"
  #  #puts "Melhores resutlados interseccao"
  #  #puts ""
  #  #profit = {}
  #  #confs = {}
  #  #best_profit.each do |poss|
  #  #  net = 0
  #  #  line = []
  #  #  total_results.keys.each do |day|
  #  #    profit = total_results[day].select {|rs| rs[:poss] == poss}.first rescue {}
  #  #    net += profit[:net]
  #  #    line << "Dia #{day} - Net #{profit[:net]} - Poss #{profit[:poss]}"
  #  #  end
  #  #  confs[net.to_s] = line
  #  #end
  #  #
  #  #confs.keys.sort {|a, b| a.to_i <=> b.to_i}.last(3).each do |net|
  #  #  puts "Lucro: #{net}"
  #  #  confs[net].each {|l| p l}
  #  #end
  #end

  def self.by_possibility(possibilities,index=4)
    puts
    possibilities.sort! { |a,b| a[:net] <=> b[:net] }

    puts "- #{index} worst results"
    possibilities.first(index).each_with_index do |poss,i|
      format_result(poss,index-i)
    end

    puts "- #{index} best results"
    possibilities.last(index).each_with_index do |poss,i|
      format_result(poss,index-i)
    end
  end

  private
  def self.format_result(poss, index)
    rs = poss.select {|k, v| k.to_s != "per_day" }
    puts "[#{index}]Net: #{poss[:net]} - Poss #{rs}"

    (poss[:per_day] || []).to_a.sort! { |a,b| a[:date] <=> b[:date] }

    (poss[:per_day] || []).to_a.each do |day|
      puts " - Dia: #{day[:date].strftime("%d/%m/%Y")} - Net: #{day[:net]}"
    end
  end
end
