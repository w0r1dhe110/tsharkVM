#
# Created by Martin Kacer
# Copyright 2020 H21 lab, All right reserved, https://www.h21lab.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "json"

# Add additional protocol layers if needed and regenerate the json by this script
# tshark mapping json was created by the following command 
# tshark -G elastic-mapping --elastic-mapping-filter frame,eth,ip,udp,tcp,dhcp > tshark_mapping_template.json

# json contains duplicated values, deduplicate it by this ruby script
input = open("#{Dir.pwd}/Kibana/template_tshark_mapping.json")
json = input.read

parsed = JSON.parse(json)

# Optionally replace date values and convert it to floats
#replace_date(parsed)

# Optionally drop the whole mappings and just use dynamic
# This is here because the mapping for all protocols is causing Kibana to freeze during create index pattern
#parsed['mappings']['doc']['properties'].delete('layers')

parsed['settings']['index.mapping.ignore_malformed'] = true
parsed['settings']['index.mapping.coerce'] = true
parsed['mappings']['doc']['dynamic'] = true

# Optionally overwite various fields here if needed
#parsed['mappings']['doc']['properties']['layers']['properties']['frame']['properties']['frame_frame_time'] = {"type"=>"text"}

output = File.open("#{Dir.pwd}/Kibana/template_tshark_mapping_deduplicated.json","w")
output.write(JSON.pretty_generate(parsed))


############## Methods #############
def replace_date(h)
  h.each do |k, v| 
    if v.is_a?(Hash) || v.is_a?(Array)
      replace_date(v)
    else
      if (v == "date")
        h[k] = "float"
      end
    end
  end
end