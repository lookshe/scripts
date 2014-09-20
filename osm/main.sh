#!/bin/bash
#set -x

#configuration
config_file=/home/osm/convert/scripts/config.cfg

# source a specified section from config
function source_section {
   section_name="$1"
   section_start="^\[$section_name\]$"
   section_end="^\[/$section_name\]$"

   line_start=$(grep -n "$section_start" "$config_file" | cut -d: -f1)
   line_end=$(expr $(grep -n "$section_end" "$config_file" | cut -d: -f1) - 1)
   line_diff=$(expr $line_end - $line_start)

   tmpfile=$(mktemp)
   head -n $line_end "$config_file" | tail -n $line_diff > "$tmpfile"
   source "$tmpfile"
   rm -f "$tmpfile"
}

# general section from config
source_section "general"

export osmosis_executable dir_maps dir_output dir_stage dir_poly filetype_osm filetype_map filetype_poly wget_limit_rate

params_for_xarg_call=""

#loop over the maps we want to generate
for act_country in $maps_to_generate
do
   # reset defaults
   wm_type="$default_type"
   start_zoom="$default_start_zoom"
   language="$default_language"
   use_poly="$default_use_poly"

   source_section "$act_country"

   if [ "X$output_subdir" == "X" ]
   then
      output_subdir="."
   fi

   params_for_xarg_call="$params_for_xarg_call \"$download_base_url/$download_map_path/$download_map_file.$filetype_osm\" \"$download_base_url/$download_poly_path/$download_poly_file.$filetype_poly\" \"$act_country.$filetype_map\" \"$wm_type\" \"$start_zoom\" \"$language\" \"$use_poly\" \"$output_subdir\""
done

#echo "$params_for_xarg_call" | xargs -n 8 -P $threads_to_start echo
echo "$params_for_xarg_call" | xargs -n 8 -P $threads_to_start $download_and_convert_script
