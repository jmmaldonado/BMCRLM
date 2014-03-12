###
# WSDL:
#   name: Location of the WSDL
#   position: A1:F1
#   type: in-text
#   required: yes
# Action:
#   name: WebService action to be called
#   position: A2:F2
#   type: in-external-single-select
#   external_resource: ws_soap_availableActions
#   required: yes
# Body:
#   name: SOAP Body
#   position: A3:F5
#   type: in-text
###

require 'savon' 

# Flag the script for direct execution
params["direct_execute"] = true

begin 

  write_to params["WSDL"]
  write_to params["Action"]
  write_to params["Body"]

  client = Savon.client(params["WSDL"])
  client.config.log_level = :info
  response = client.request "#{params['Action']}" do
    soap.input = ["#{params['Action']}", {"xmlns" => "http://ws.cdyne.com/WeatherWS/"}]
    soap.element_form_default = :unqualified
    #http.headers["SOAPAction"] = '"http://ws.cdyne.com/WeatherWS/' + params['Action'] + '"'
    #http.headers["SOAPAction"] = '""'
    http.headers.delete("SOAPAction") 
    soap.body = params["Body"] 
    #soap.body = '"<ZIP>90210</ZIP>"'
  end
  
  write_to "=== SOAP ==="
  write_to client.soap.to_xml
  
  write_to "=== RESPONSE ==="
  write_to response.inspect

rescue => e
  write_to "== RAMA RESCUE =="
  write_to("Operation failed: #{e.message}, Backtrace:\n#{e.backtrace.inspect}")
end  
