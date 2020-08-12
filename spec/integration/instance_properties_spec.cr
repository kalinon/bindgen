require "./spec_helper"

describe "C++ instance properties" do
  it "works" do
    build_and_run("instance_properties") do
      # expose private methods as public ones
      class MyProps < Test::Props
        def x_prot
          super
        end

        def x_prot=(x)
          super
        end

        def y_prot
          super
        end
      end

      context "getter methods" do
        it "is generated for public members" do
          props = Test::Props.new(5, 8)
          props.x_pub.should eq(5)
          props.y_pub.should eq(8)
        end

        it "is generated for protected members" do
          props = MyProps.new(5, 8)
          props.x_prot.should eq(105)
          props.y_prot.should eq(108)

          {% begin %}
            {% method = Test::Props.methods.find &.name.== "x_prot" %}
            {{ method.visibility }}.should eq(:private)
            {% method = Test::Props.methods.find &.name.== "y_prot" %}
            {{ method.visibility }}.should eq(:private)
          {% end %}
        end

        it "is ignored for private members" do
          {{ Test::Props.has_method?("x_priv") }}.should be_false
          {{ Test::Props.has_method?("y_priv") }}.should be_false
        end

        it "supports pointer members" do
          position = Test::Props.new(5, 8).position_ptr
          position.should be_a(Test::Point)
          position.x.should eq(12)
          position.y.should eq(34)
        end

        it "supports class-type value members" do
          position = Test::Props.new(5, 8).position_val
          position.should be_a(Test::Point)
          position.x.should eq(13)
          position.y.should eq(35)
        end
      end

       context "setter methods" do
        it "is generated for public members" do
          props = Test::Props.new(5, 8)
          props.x_pub = 7
          props.x_pub.should eq(7)
        end

        it "is generated for protected members" do
          props = MyProps.new(5, 8)
          props.x_prot = 7
          props.x_prot.should eq(7)

          {% begin %}
            {% method = Test::Props.methods.find &.name.== "x_prot=" %}
            {{ method.visibility }}.should eq(:private)
          {% end %}
        end

        it "is ignored for private members" do
          {{ Test::Props.has_method?("x_priv=") }}.should be_false
        end

        it "is ignored for const members" do
          methods = {{ Test::Props.methods.map &.name.stringify }}
          methods.includes?("y_pub=").should be_false
          methods.includes?("y_prot=").should be_false
          methods.includes?("y_priv=").should be_false
        end

        it "supports pointer members" do
          props = Test::Props.new(5, 8)
          props.position_ptr = Test::Point.new(60, 61)
          got = props.position_ptr
          got.x.should eq(60)
          got.y.should eq(61)
        end

        it "supports class-type value members" do
          props = Test::Props.new(5, 8)
          props.position_val = Test::Point.new(60, 61)
          got = props.position_val
          got.x.should eq(60)
          got.y.should eq(61)
        end
      end
    end
  end
end