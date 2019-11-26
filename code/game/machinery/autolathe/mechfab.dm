/obj/machinery/autolathe/mechfab
	name = "exosuit fabricator"
	desc = "A machine used for construction of robots and mechas."
	icon_state = "mechfab"
	circuit = /obj/item/weapon/circuitboard/mechfab

	storage_capacity = 240
	speed = 3

	have_disk = FALSE
	have_reagents = FALSE
	have_recycling = FALSE

	special_actions = list(
		list("action" = "sync", "name" = "Sync with R&D console", "icon" = "refresh")
	)

	var/datum/research/files


/obj/machinery/autolathe/mechfab/Initialize()
	. = ..()
	files = new /datum/research(src)

/obj/machinery/autolathe/mechfab/design_list()
	var/list/designs = list()

	for(var/i in files.known_designs)
		var/datum/design/D = i
		if(!(D.build_type & MECHFAB) || !D.file)
			continue

		designs |= D.file

	return designs

/obj/machinery/autolathe/mechfab/ui_interact()
	if(!categories)
		update_categories()
	..()

/obj/machinery/autolathe/mechfab/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["action"] == "sync")
		sync(usr)
		return 1

/obj/machinery/autolathe/mechfab/proc/sync(mob/user)
	var/sync = FALSE

	for(var/obj/machinery/computer/rdconsole/RDC in get_area_all_atoms(get_area(src)))
		if(!RDC.sync)
			continue
		files.download_from(RDC.files)
		to_chat(user, SPAN_NOTICE("Sync with [RDC] complete."))
		sync = TRUE

	if(!sync)
		to_chat(user, SPAN_WARNING("Error: no research console with enabled sync was found."))

	update_categories()

/obj/machinery/autolathe/mechfab/proc/update_categories()
	categories = list()
	for(var/datum/design/D in files.known_designs)
		if(!(D.build_type & MECHFAB))
			continue
		categories |= D.category

	if((!show_category || !(show_category in categories)) && length(categories))
		show_category = categories[1]