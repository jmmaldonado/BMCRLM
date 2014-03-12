###
# workingDirectory:
#   name: Directorio en el que descargar la working copy
# SVNUser:
#   name: Usuario del repositorio SVN
# SVNPassword:
#   name: Password del usuario SVNUser
# SVNRepo:
#   name: Repositorio del SVN del que descargar el contenido
###

#=== Streamstep Integration Server: BRPM ===#
# [integration_id=1]
SS_integration_dns = "http://localhost:10080/brpm/v1"
SS_integration_username = "admin"
SS_integration_password = "-private-"
SS_integration_details = ""
SS_integration_password_enc = "__SS__Cj1RbWN3YzNjekZHYw=="
#=== End ===#

# Flag the script for direct execution
params["direct_execute"] = true

#==============  User Portion of Script ==================

revision = ""
if !params["component_version"].empty?
  revision = "-r #{params["component_version"]}"
end 

puts "\nConsultando en SVN la revision: #{params["component_version"]}\n"

params["command"] = "\"C:\\Program Files (x86)\\Subversion\\bin\\svn.exe\" co http://172.16.0.55:81/svn/#{params["SVNRepo"]} #{params["workingDirectory"]} --username #{params["SVNUser"]} --password #{params["SVNPassword"]} #{revision}"

# Run the command directly on the localhost
result = run_command(params, params["command"], '')

params["success"] = "Checked out revision"

#Buscamos el texto de resultado correcto
indice = result.index(params["success"])

# Apply success or failure criteria
if indice.nil?
  write_to "Command_Failed - term not found: [#{params["success"]}]\n"
else
  #Recogemos el valor de la version
  temporal = result[indice, result.length]
  
  #Nos quedamos con "revision xxx."
  temporal2 = temporal[temporal.index("revision"), temporal.length]

  #Cogemos "xxx."
  temporal3 = temporal2.split(" ")[1]

  #Cogemos la version
  coVersion = temporal3[0, temporal3.length - 1]

  prop = "DE_AppVersion"
  comp_id = "14"
  env = "Dev"
  prop_val = coVersion
  RPM_TOKEN = "4a16cb186a2885d56a60f84d06b599746aadeba7"
  RPM_BASE_URL = SS_integration_dns 

  request_doc_xml = "<installed_component><properties_with_values><#{prop}>#{prop_val}</#{prop}></properties_with_values></installed_component>"
  url = "#{RPM_BASE_URL}/installed_components/#{comp_id}?token=#{RPM_TOKEN}"
  cmd='C:\\Windows\\System32\\curl.exe -s -H "accept:application/json" -H "Content-type: text/xml" -X PUT -d "' + request_doc_xml + '" ' + url

  response = `#{cmd}`

  #Escribimos la version en el fichero de intercambio
  targetFolder = "c:\\RPMExchange"
  if !File.directory? targetFolder
    Dir::mkdir(targetFolder)
  end

  fichero = targetFolder + "\\version.txt"
  File.open(fichero, 'w') { |file| file.write("#{coVersion}") }

  write_to "Success - found term: #{params["success"]}\n"

end
