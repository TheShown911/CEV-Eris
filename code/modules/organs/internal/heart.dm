/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	organ_efficiency = list(OP_HEART = 100)
	parent_organ_base = BP_CHEST
	dead_icon = "heart-off"
	price_tag = 1000
	specific_organ_size = 2
	oxygen_req = 10
	nutriment_req = 10
	var/open

/obj/item/organ/internal/heart/open
	open = 1
/obj/item/organ/internal/heart/proc/is_working()
	if(!is_usable())
		return FALSE

	return owner.pulse > PULSE_NONE || BP_IS_ROBOTIC(src) || (owner.status_flags & FAKEDEATH)


/obj/item/organ/internal/heart/robotize()
	..()
	replace_self_with(/obj/item/organ/internal/heart/machine)

/obj/item/organ/internal/heart/machine //O_PUMP
	name = "hydraulic hub"
	icon_state = "pump-on"
	dead_icon = "pump-off"
	nature = MODIFICATION_SILICON
	specific_organ_size = 1
	owner_verbs = list(
		/obj/item/organ/internal/heart/machine/proc/owner_self_diagnostics
	)


/obj/item/organ/internal/heart/machine/proc/owner_self_diagnostics()	//A bit hacky, but it works
	set name = "Self-Diagnostics"
	set desc = "Run an internal self-diagnostic to check for damage."
	set category = "IC"

	owner.self_diagnostics()
