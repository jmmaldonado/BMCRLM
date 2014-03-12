###
# WSDL:
#   name: Location of the WSDL
#   position: A1:F1
#   required: yes
###

require 'savon'

def camel_case
  return self if self !~ /_/ && self =~ /[A-Z]+.*/
  split('_').map{|e| e.capitalize}.join
end

def execute(script_params, parent_id, offset, max_records)
	soap_actions = []
	if script_params["WSDL"]
		client = Savon.client(script_params['WSDL'])
		client.wsdl.soap_actions.each do |act|
                        actCamel = act.to_s.split('_').map{|e| e.capitalize}.join
			soap_actions << { actCamel => actCamel }
		end
	end
	
	return soap_actions
	
end
