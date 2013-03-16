class SimpleCommand < Mutations::Command

  required do
    string :full_name, max_length: 10
    string :email
  end

  optional do
    integer :amount
  end

  def execute
    inputs
  end
end