#Active Record Lite


This is an Object Relational Mapping (ORM) set of classes and modules inspired by Active Record.


What's included:
* Getter and Setter methods included in attr_accessor
* Save, Update, Insert, and Find methods in the SQLObject class
* Where method which protects from SQL injection found in the Searchable module
* belongs_to, has_many and has_one_through methods found in the Associatable module

All is packaged together with active_record_lite.rb, however you can require them individually if you wish.

How you would use it:

```ruby
# First, require the library
require 'active_record_lite'
# I've included a cats database, so cats belong to humans, who have many houses and cats have one house through the human. So my examples will use these. However, if you have a different database, just include sqlite3.


# Now, have your classes inherit from SQLObject. You can set up associations here.
class Cat < SQLObject
  belongs_to :human, foreign_key: :owner_id
  has_one_through :apartment, :human, :apartments

  finalize!
end

class Human < SQLObject
  has_many :cats, foreign_key: :owner_id
  has_many :apartments

  finalize!
end

#let's make my cat, Debbie
debbie = Cat.new(name: "Debbie", owner_id: 1) #id of this cat is 1
debbie.save

# now we can find Debbie with either the find method, using its id
Cat.find(1)
=> #<Cat:0x007f9e07011100 @attributes={:id=>1, :name=>"Debbie", :owner_id=>1}>

#we can also find Debbie with the where method
debbie = Cat.where(name: "Debbie")
=> [#<Cat:0x007f9e04adb070 @attributes={:id=>1, :name=>"Debbie", :owner_id=>1}>]



#we can also use the associations to find the owners
debbie.human
=> [#<Human:0x004h9b03cba052 @attributes={:id=>1, :first_name=>"Eric", :last_name=>"Firth"}>]

#or even where debbie lives
debbie.apartment
=> #<Apartment:0x007f9e04a90520 @attributes={:id=>1, :address=>"censored", :city=>"Brooklyn"}>

```

Thanks!
