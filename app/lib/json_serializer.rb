module JSONSerializer
	DEFAULT_DUMP = 'null'

	def self.dump(obj)
		obj.to_json
	end

	def self.load(str)
		JSON.parse(str || DEFAULT_DUMP, symbolize_names: true)
	end
end
