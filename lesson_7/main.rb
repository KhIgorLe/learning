=begin
Создать программу в файле main.rb, которая будет позволять пользователю через текстовый интерфейс делать следующее:
     - Создавать станции
     - Создавать поезда
     - Создавать маршруты и управлять станциями в нем (добавлять, удалять)
     - Назначать маршрут поезду
     - Добавлять вагоны к поезду
     - Отцеплять вагоны от поезда
     - Перемещать поезд по маршруту вперед и назад
     - Просматривать список станций и список поездов на станции

В качестве ответа приложить ссылку на репозиторий с решением
=end

require_relative 'train'
require_relative 'passenger_train'
require_relative 'cargo_train'
require_relative 'passenger_wagon'
require_relative 'freight_wagon'
require_relative 'route'
require_relative 'station'
require_relative 'wagon'

class Main
  MAIN_MENU = <<-MENU
    Выберите пункт меню:
    Введите 1 - cоздавать станции
    Введите 2 - создавать поезда
    Введите 3 - создавать маршруты
    Введите 4 - добавить станцию в маршрут
    Введите 5 - удалить станцию в маршруте 
    Введите 6 - назначать маршрут поезду
    Введите 7 - Добавлять вагоны к поезду
    Введите 8 - Отцеплять вагоны от поезда
    Введите 9 - Перемещать поезд по маршруту вперед
    Введите 10 - Перемещать поезд по маршруту назад
    Введите 11 - Просматривать список станций и список поездов на станции
    Введите 12 - Просматривать станции у поезда
    Введите 13 - Просматривать список вагонов для поезда
    Введите 14 - Занять место или объем в вагоне
    Введите 0 - Выйти из программы
  MENU

  def initialize
    @stations = []
    @routs = []
    @trains = []
    @wagons = []
    @count_stations = 0
  end

  def run
    command = ""
    while command != 0
      puts MAIN_MENU
      command = gets.to_i
      case command
      when 1 then create_station
      when 2 then create_train
      when 3 then create_route
      when 4 then add_station_in_route
      when 5 then del_station_in_route
      when 6 then take_route_for_train
      when 7 then add_wagon_for_train
      when 8 then del_wagon_for_train
      when 9 then move_train_route_forward
      when 10 then move_train_route_back
      when 11 then show_list_trains_for_station
      when 12 then show_station_for_train
      when 13 then show_list_wagons_for_train
      when 14 then take_volume_in_wagon
      when 0 then break
      else
        puts "Команда введена не правильно"
      end
    end
  end

  private

  def create_station
    puts "Введите название станции"
    name = gets.chomp
    if station_present?(name)
      puts "Станция уже существует"
    else
      @stations << Station.new(name)
      @count_stations += 1
      puts "Станция #{name} создана"
    end
  end

  def station_present?(name)
    @stations.map(&:name).include?(name)
  end

  def create_train
    puts "Введите номер поезда"
    number = gets.chomp
    puts "Выберите 1 - создать пассажирский, 2 - создать грузовой поезд"
    choise = gets.to_i
    case choise
    when 1
      train = PassengerTrain.new(number)
      @trains << train
      puts "Пассажирский поезд номер #{number} создан"
    when 2
      train = CargoTrain.new(number)
      @trains << train
      puts "Грузовой поезд номер #{number} создан"
    end
  rescue RuntimeError => e
    puts e.message
    retry
  end

  def create_route
    if @stations.empty?
      station_text
      puts "Необходимо как минимум две станции"
    elsif @count_stations < 2
      puts "Для создания маршрута необходимо создать две станции, первая станция уже создана"
    else
      route = Route.new(@stations.first, @stations.last)
      @routs << route
      puts "Маршрут со станцциями #{@stations.first.name}, #{@stations.last.name} создан"
    end
  end

  def add_station_in_route
    if @stations.empty?
      station_text
    elsif @routs.empty?
      puts "Вы не создали маршрут"
    else
      get_route.add_intermediate_station(get_station)
    end
  end

  def del_station_in_route
    if @stations.empty?
      station_text
    elsif @routs.empty?
      puts "Вы не создали маршрут"
    else
      get_route.del_intermediate_station(get_station)
    end
  end

  def take_route_for_train
    if @routs.empty?
      puts "Вы не создали маршрут"
    elsif @trains.empty?
      create_train_text
    else
      get_train.take_route(get_route)
    end
  end

  def add_wagon_for_train
    if @trains.empty?
      create_train_text
    else
      train = get_train
      return if train.speed != 0
      wagon_class = train.accept_class_wagon
      if wagon_class == PassengerWagon
        select_wagon_text
        number_wagon = gets.to_i
        puts "Введите количество мест в вагоне"
        quantity_all_places = gets.to_i
        wagon = wagon_class.new(number_wagon, quantity_all_places)
        train.add_wagon(wagon)
        @wagons << wagon
      elsif wagon_class == FreightWagon
        select_wagon_text
        number_wagon = gets.to_i
        puts "Введите объем вагона"
        total_volume = gets.to_i
        wagon = wagon_class.new(number_wagon, total_volume)
        train.add_wagon(wagon)
        @wagons << wagon
      end
    end  
  end

  def del_wagon_for_train
    if @trains.empty?
      create_train_text
    elsif @wagons.empty?
      add_wagon_text
    else
      train = get_train
      train.del_wagon(get_wagon) if train.speed == 0
    end
  end

  def move_train_route_forward
    if @trains.empty?
      create_train_text
    else
      get_train.go_next_station
    end
  end

  def move_train_route_back
    if @trains.empty?
      create_train_text
    else
      get_train.go_previouse_station
    end
  end

  def take_volume_in_wagon
    if @wagons.empty?
      add_wagon_text
    else
      train = get_train
      wagon = select_wagon_for_train(train)
      wagon_class = train.accept_class_wagon
      if wagon_class == PassengerWagon
        wagon.take_volume
      elsif wagon_class == FreightWagon
        puts "Введите объем груза"
        volume = gets.to_i
        wagon.take_volume(volume)
      end
    end
  end

  def show_list_trains_for_station
    @stations.each do |station|
      puts "На станции #{station.name} находятся поезда:"
      station.each_trains do |train|
        puts "Номер поезда #{train.number}, Тип #{train.type}, Количество вагонов - #{train.wagons.size}"
      end
    end
  end

  def show_list_wagons_for_train
    @trains.each do |train|
      puts "У поезда номер #{train.number}:"
      wagon_class = train.accept_class_wagon
      train.each_wagon do |wagon|
        if wagon_class == PassengerWagon
          information_wagon(wagon, train)
        elsif wagon_class == FreightWagon
          information_wagon(wagon, train)
        end
      end
    end
  end

  def show_station_for_train
    train = get_train
    puts "Поезд #{train.number} имеет станции:"
    train.route.stations.each { |station| puts "#{station.name }" }
  end

  def get_train
    @trains.each_with_index { |train, number| puts "поезд #{train.number} - номер #{number}" }
    puts "Выберите номер поезд"
    train = gets.to_i
    @trains[train]
  end

  def get_route
    @routs.each_with_index { |route, number| puts "маршрут #{route.name} - номер #{number}" }
    puts "Введите номер маршрута"
    number_route = gets.to_i
    @routs[number_route]
  end

  def get_station
    @stations.each_with_index { |station, number| puts "станция #{station.name} - номер #{number}"}
    puts "Введите номер станции"
    number_station = gets.to_i
    @stations[number_station]
  end

  def get_wagon
    @wagons.each_with_index {|wagon, number| puts "Вагон номер #{wagon.number} - номер #{number}"}
    select_wagon_text
    wagon = gets.to_i
    @wagons[wagon]
  end

  def select_wagon_for_train(train)
    train.wagons.each_with_index { |wagon, number| puts "Вагон номер #{wagon.number} - номер #{number}" }
    select_wagon_text
    wagon = gets.to_i
    train.wagons[wagon]
  end

  def information_wagon(wagon, train)
    a = "Вагон номер #{wagon.number}: типа вагона #{train.type},"       
    if train.accept_class_wagon == PassengerWagon
      puts "#{a} свободных мест #{wagon.empty_volume}, занятых мест #{wagon.occupied_volume}"
    elsif train.accept_class_wagon == FreightWagon
      puts "#{a} свободный объём #{wagon.empty_volume}, занятый объём #{wagon.occupied_volume}"
    end
  end

  def station_text
    puts "Вы не создали станцию"
  end

  def create_train_text
    puts "Создайте поезд"
  end

  def select_wagon_text
    puts "Введите номер вагона"
  end

  def add_wagon_text
    puts "Добавьте вагон к поезду"
  end
end

Main.new.run
