module Puppet::Pops
module Loader

# Runtime3TypeLoader
# ===
# Loads a resource type using the 3.x type loader
#
# @api private
class Runtime3TypeLoader < BaseLoader
  def initialize(parent_loader, environment)
    super(parent_loader, environment.name)
    @environment = environment
  end

  def to_s()
    "(Runtime3TypeLoader '#{loader_name()}')"
  end

  # Finds typed/named entity in this module
  # @param typed_name [TypedName] the type/name to find
  # @return [Loader::NamedEntry, nil found/created entry, or nil if not found
  #
  def find(typed_name)
    if typed_name.type == :type
      name = typed_name.name
      value = @environment.known_resource_types.find_definition(name)
      if value.nil?
        # Look for Puppet::Type
        if Puppet::Type.type(name).nil?
          # Cache the fact that it wasn't found
          set_entry(typed_name, nil)
        else
          # Loaded types doesn't have the same life cycle as this loader, so we must start by
          # checking if the type was created. If it was, an entry will already be stored in
          # this loader. If not, then it was created before this loader was instantiated and
          # we must therefore add it.
          value = get_entry(typed_name)
          value = set_entry(typed_name, Types::TypeFactory.resource(name.capitalize)) if value.nil?
          value
        end
      else
        set_entry(typed_name, Types::TypeFactory.resource(name.capitalize))
      end
    else
      nil
    end
  end
end
end
end
