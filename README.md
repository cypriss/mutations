hello

# External API:
# Class.run(...)
# Class.run!(...)

# result API:
# mutation.success?
# mutation.result
# mutation.errors

# internal API:
# def execute; end # what you define
# self.inputs
# self.name # accessors
# self.name = "bob" # setter
# self.name_present? # test to see if a key was passed
# self.add_error(:name, :too_long, "That name is too long")
# self.merge_errors(ErrorHash instance)

# TODO: make command methods private/protected

