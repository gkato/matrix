class Reporter

  def self.report(total_results)
    best_profit = []
    profit = []
    puts ""
    total_results.keys.each do |day|
      profit << total_results[day].select {|rs| rs[:net] > 0}

      result = total_results[day]

      puts "#################"
      puts "Resultado do dia #{day}"
      puts ""

      puts "- 3 piores resultados"
      result.first(3).each do |rs|
        puts "Net: #{rs[:net]} - Poss #{rs[:poss]}"
      end

      puts ""

      puts "- 3 melhores resultados"
      result.last(3).each do |rs|
        puts "Net: #{rs[:net]} - Poss #{rs[:poss]}"
      end
      puts ""
    end

    #possibilities.each do |poss|
    #  inter = true
    #  profit.each do |pro|
    #    match = pro.find {|net| net[:poss] == poss}
    #
    #    if match.nil? || match.empty?
    #      inter = false;
    #    end
    #  end
    #  if inter
    #    best_profit << poss
    #  end
    #end
    #
    #puts ""
    #puts "#################"
    #puts "Melhores resutlados interseccao"
    #puts ""
    #profit = {}
    #confs = {}
    #best_profit.each do |poss|
    #  net = 0
    #  line = []
    #  total_results.keys.each do |day|
    #    profit = total_results[day].select {|rs| rs[:poss] == poss}.first rescue {}
    #    net += profit[:net]
    #    line << "Dia #{day} - Net #{profit[:net]} - Poss #{profit[:poss]}"
    #  end
    #  confs[net.to_s] = line
    #end
    #
    #confs.keys.sort {|a, b| a.to_i <=> b.to_i}.last(3).each do |net|
    #  puts "Lucro: #{net}"
    #  confs[net].each {|l| p l}
    #end
  end

  def self.by_possibility(possibilities)
    puts
    possibilities.sort! { |a,b| a[:net] <=> b[:net] }

    puts "- 3 piores resultados"
    possibilities.first(3).each do |poss|
      format_result poss
    end

    puts "- 3 melhores resultados"
    possibilities.last(3).each do |poss|
      format_result poss
    end
  end

  private
  def self.format_result(poss)
    rs = poss.select {|k, v| k.to_s != "per_day" }
    puts "Net: #{poss[:net]} - Poss #{rs}"
  end
end
