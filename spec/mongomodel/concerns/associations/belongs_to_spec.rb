require 'spec_helper'

module MongoModel
  shared_examples_for "assigning correct class to belongs_to association" do
    define_class(:User, Document)
    define_class(:SpecialUser, :User)

    let(:user) { User.create! }
    let(:special_user) { SpecialUser.create! }
    
    subject { Article.new }
    
    context "when uninitialized" do
      it "should be nil" do
        subject.user.should be_nil
      end
      
      it "should be settable" do
        subject.user = user
        subject.user.should == user
      end
      
      it "should not be truthy" do
        subject.user.should_not be_truthy
      end
      
      describe "setting a subclass type" do
        it "should set successfully" do
          subject.user = special_user
          subject.user.should == special_user
        end
      end
    end
    
    context "when loading from database" do
      subject { Article.new(:user => user) }
      
      if specing?(EmbeddedDocument)
        define_class(:ArticleParent, Document) do
          property :article, Article
        end
        
        let(:parent) { ArticleParent.create!(:article => subject) }
        let(:reloaded) { ArticleParent.find(parent.id).article }
      else
        before(:each) { subject.save! }
        let(:reloaded) { Article.find(subject.id) }
      end
      
      it "should access the user through the association" do
        reloaded.user.should == user
      end
      
      it "should be truthy" do
        subject.user.should be_truthy
      end
      
      it "should allow the user to be reloaded" do
        user = reloaded.user.target
        
        user.should equal(reloaded.user.target)
        user.should equal(reloaded.user.target)
        user.should_not equal(reloaded.user(true).target)
      end
      
      describe "setting a subclass type" do
        subject { Article.new(:user => special_user) }
        
        it "should load successfully" do
          reloaded.user.should == special_user
        end
      end
    end
  end
  
  specs_for(Document, EmbeddedDocument) do
    describe "belongs_to association" do
      define_class(:Article, described_class) do
        belongs_to :user
      end
      
      it_should_behave_like "assigning correct class to belongs_to association"
      
      describe "setting a different class type" do
        define_class(:NonUser, Document)
        
        let(:non_user) { NonUser.create! }
        
        it "should raise a AssociationTypeMismatch exception" do
          lambda { subject.user = non_user }.should raise_error(AssociationTypeMismatch, "expected instance of User but got NonUser")
        end
      end
      
      describe "#build_user" do
        subject { Article.new }
        
        let(:user) { subject.build_user(:id => '123') }
        
        it "should return a new unsaved user with the given attributes" do
          user.should be_an_instance_of(User)
          user.should be_a_new_record
          user.id.should == '123'
        end
      end
      
      describe "#create_user" do
        subject { Article.new }
        
        it "should return a new saved user with the given attributes" do
          user = subject.create_user(:id => '123')
          user.should be_an_instance_of(User)
          user.should_not be_a_new_record
          user.id.should == '123'
        end
      end
    end
    
    describe "polymorphic belongs_to association" do
      define_class(:Article, described_class) do
        belongs_to :user, :polymorphic => true
      end
      
      define_class(:NonUser, Document)
      
      let(:non_user) { NonUser.create! }
      
      it_should_behave_like "assigning correct class to belongs_to association"
      
      describe "setting a different class type" do
        it "should set successfully" do
          subject.user = non_user
          subject.user.should == non_user
        end
      end
      
      context "when loading from database" do
        subject { Article.new(:user => user) }
        
        if specing?(EmbeddedDocument)
          define_class(:ArticleParent, Document) do
            property :article, Article
          end
          
          let(:parent) { ArticleParent.create!(:article => subject) }
          let(:reloaded) { ArticleParent.find(parent.id).article }
        else
          before(:each) { subject.save! }
          let(:reloaded) { Article.find(subject.id) }
        end
        
        describe "setting a different class type" do
          subject { Article.new(:user => non_user) }
          
          it "should load successfully" do
            reloaded.user.should == non_user
          end
        end
      end
    end
  end
end
