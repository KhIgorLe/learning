=begin
Имеет начальную и конечную станцию, а также список промежуточных станций.
Начальная и конечная станции указываютсся при создании маршрута, а промежуточные могут добавляться между ними.
Может добавлять промежуточную станцию в список
Может удалять промежуточную станцию из списка
Может выводить список всех станций по-порядку от начальной до конечной
=end

require_relative 'instance_counter'
require_relative 'valid'

class Route
  include InstanceCounter
  include Valid
  attr_reader :stations, :name

  def initialize(begin_station, end_station)
    @stations = [begin_station, end_station]
    @name = "#{begin_station.name} - #{end_station.name}"
    validate!
    register_instance
  end

  def add_intermediate_station(name_station)
    @stations.insert(-2, name_station)
  end

  def del_intermediate_station(name_station)
    @stations.delete(name_station) unless [@stations.first, @stations.last].include?(name_station)
  end

  def list_all_station
    @stations.each { |name| puts "Станция #{name}" }
  end

  protected

  def validate!
    raise "Маршрут не может быть без станций" if @stations.first.nil? || @stations.last.nil?
    raise "Маршурт создан не из станций" unless @stations.last.is_a?(Station) && @stations.first.is_a?(Station)
  end
end
