class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql =<<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =<<-SQL
    DROP TABLE IF EXISTS dogs;
    );
    SQL
    DB[:conn].execute(sql)
  end

   def save
     sql =<<-SQL
     INSERT INTO dogs (name, breed) VALUES (?, ?);
     );
     SQL
     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
     self
   end

   def self.create(name:, breed:)
     dog = Dog.new(name: name, breed: breed)
     dog.save
     dog
   end

   def self.find_by_id(id)
     sql =<<-SQL
     SELECT * FROM dogs WHERE id = ?;
     );
     SQL
     db = DB[:conn].execute(sql, id)[0]
     new_dog = Dog.new(id: db[0], name: db[1], breed: db[2])
     new_dog
   end

  def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed =?;", name, breed)
      if !dog.empty?
        dog_data = dog[0]
        found_or_created_dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else
        found_or_created_dog = self.create(name: name, breed: breed)
      end
      found_or_created_dog
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self.find_by_name(name)
    sql =<<-SQL
    SELECT * FROM dogs WHERE name = ?;
    );
    SQL
    db = DB[:conn].execute(sql, name)[0]
    dog = Dog.new(id: db[0], name: db[1], breed: db[2])
    dog
  end

  def update
    sql =<<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    );
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
