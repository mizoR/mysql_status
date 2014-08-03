require 'mysql_status/version'
require 'active_support/inflector/methods'
require 'active_record/connection_adapters/mysql2_adapter'

module MysqlStatus
  class State
    def initialize(state)
      @state = {}.tap {|_state|
        state.each {|key, value| _state[key] = cast(value)}
      }
    end

    def [](key)
      @state[key.to_s]
    end

    def method_missing(method_name, *args)
      method_name = method_name.to_s
      if @state.has_key?(method_name)
        self[method_name]
      else
        super
      end
    end

    def respond_to?(method_name)
      method_name = method_name.to_s
      @state.has_key?(method_name) || super
    end

    private

    def cast(value)
      case value.to_s
      when /\A\d+\z/
        value.to_i
      when /\A(?:\d+\.\d*|\.\d+)\z/
        value.to_f
      else
        value
      end
    end
  end

  class Base
    include Enumerable

    def initialize(connection, command)
      @status = connection.select("SHOW #{command}").map {|state|
        State.new(state)
      }
    end

    def each
      @status.each do |state|
        yield(state)
      end
    end

    [:detect, :find, :select, :find_all].each do |method|
      define_method :"#{method}_by" do |conditions={}|
        @status.send(method) {|_state|
          conditions.all? {|key, value| _state[key.to_s] == value}
        }
      end
    end
  end

  SHOW_COMMANDS = {
    status:         'STATUS',
    global_status:  'GLOBAL STATUS',
    innodb_status:  'INNODB STATUS',
    master_status:  'MASTER STATUS',
    session_status: 'SESSION STATUS',
    slave_status:   'SLAVE STATUS',
  }

  SHOW_COMMANDS.each do |name, command|
    class_name = name.to_s.camelize
    status_class = Class.new(Base) {
      define_method :initialize do |connection|
        super(connection, command)
      end
    }

    const_set(class_name, status_class)

    define_method name do
      status_class.new(self)
    end
  end
end

ActiveRecord::ConnectionAdapters::Mysql2Adapter.include MysqlStatus
