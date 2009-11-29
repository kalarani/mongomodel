require 'spec_helper'

describe MongoModel do
  it "should have a database accessor" do
    db = MongoModel.database
    connection = db.connection
    
    connection.host.should == 'localhost'
    connection.port.should == 27017
    db.name.should == 'mydb'
  end
end
