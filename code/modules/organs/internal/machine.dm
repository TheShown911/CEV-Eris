/obj/item/organ/internal/cell
	name = "microbattery"
	desc = "A small, powerful cell for use in fully prosthetic bodies."
	icon = 'icons/obj/power.dmi'
	icon_state = "scell"
	parent_organ_base = BP_CHEST
	nature = MODIFICATION_SILICON
	vital = TRUE
	var/open
	var/obj/item/weapon/cell/medium/cell = /obj/item/weapon/cell/medium
	//at 0.8 completely depleted after 60ish minutes of constant walking or 130 minutes of standing still
	var/servo_cost = 0.8 // this will probably require tweaking

/obj/item/organ/internal/cell/Initialize(mapload, ...)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)

/obj/item/organ/internal/cell/proc/percent()
	if(!cell)
		return 0
	return get_charge()/cell.maxcharge * 100

/obj/item/organ/internal/cell/proc/get_charge()
	if(!cell)
		return 0
	if(status & ORGAN_DEAD)
		return 0
	return round(cell.charge*(1 - damage/max_damage))

/obj/item/organ/internal/cell/proc/check_charge(var/amount)
	return get_charge() >= amount

/obj/item/organ/internal/cell/proc/use(var/amount)
	if(check_charge(amount))
		cell.use(amount)
		return 1

/obj/item/organ/internal/cell/proc/get_servo_cost()
	var/damage_factor = 1 + 10 * damage/max_damage
	return servo_cost * damage_factor

/obj/item/organ/internal/cell/Process()
	..()
	if(!owner)
		return
	if(owner.stat == DEAD)	//not a drain anymore
		return
	if(!is_usable())
		owner.Paralyse(3)
		return
	var/cost = get_servo_cost()
	if(world.time - owner.l_move_time < 15)
		cost *= 2
	if(!use(cost))
		if(!owner.lying && !owner.buckled)
			to_chat(owner, SPAN_WARNING("You don't have enough energy to function!"))
		owner.Paralyse(3)

/obj/item/organ/internal/cell/emp_act(severity)
	..()
	if(cell)
		cell.emp_act(severity)

/obj/item/organ/internal/cell/attackby(obj/item/weapon/W, mob/user)
	if(QUALITY_SCREW_DRIVING in W.tool_qualities)
		if(open)
			open = FALSE
			to_chat(user, SPAN_NOTICE("You screw the battery panel in place."))
		else
			open = TRUE
			to_chat(user, SPAN_NOTICE("You unscrew the battery panel."))

	if(QUALITY_PRYING in W.tool_qualities)
		if(open)
			if(cell)
				user.put_in_hands(cell)
				to_chat(user, SPAN_NOTICE("You remove \the [cell] from \the [src]."))
				cell = null

	if (istype(W, /obj/item/weapon/cell))
		if(open)
			if(cell)
				to_chat(user, SPAN_WARNING("There is a power cell already installed."))
			else if(user.unEquip(W, src))
				cell = W
				to_chat(user, SPAN_NOTICE("You insert \the [cell]."))

/obj/item/organ/internal/cell/replaced_mob(mob/living/carbon/human/target)
	..()
	// This is very ghetto way of rebooting an IPC. TODO better way.
	if(owner.stat == DEAD)
		owner.set_stat(CONSCIOUS)
		owner.visible_message(SPAN_DANGER("\The [owner] twitches visibly!"))


/obj/item/organ/internal/optical_sensor
	name = "optical sensor"
	organ_tag = "optics"
	parent_organ_base = BP_HEAD
	nature = MODIFICATION_SILICON
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	dead_icon = "camera_broken"

// Used for an MMI or posibrain being installed into a human.
/obj/item/organ/internal/mmi_holder
	name = "brain interface"
	organ_efficiency = list(BP_BRAIN = 100)
	parent_organ_base = BP_HEAD
	vital = 1
	var/brain_type = /obj/item/device/mmi
	var/obj/item/device/mmi/stored_mmi
	nature = MODIFICATION_SILICON

/obj/item/organ/internal/mmi_holder/Destroy()
	if(stored_mmi && (stored_mmi.loc == src))
		qdel(stored_mmi)
		stored_mmi = null
	return ..()

/obj/item/organ/internal/mmi_holder/New(var/obj/item/organ/external/tmp_paren)
	if(tmp_paren)
		replaced(tmp_paren)
	if(owner && istype(owner,/mob/living/carbon/human/dummy/mannequin))
		return
	stored_mmi = new brain_type(src)
	update_from_mmi()

/obj/item/organ/internal/mmi_holder/proc/update_from_mmi()

	if(!stored_mmi.brainmob)
		stored_mmi.brainmob = new(stored_mmi)
		stored_mmi.brainobj = new(stored_mmi)
		stored_mmi.brainmob.container = stored_mmi
		stored_mmi.brainmob.real_name = owner.real_name
		stored_mmi.brainmob.name = stored_mmi.brainmob.real_name
		stored_mmi.name = "[initial(stored_mmi.name)] ([owner.real_name])"

	if(!owner) return

	name = stored_mmi.name
	desc = stored_mmi.desc
	SetIcon(stored_mmi.icon)

	stored_mmi.SetIconState("mmi_full")
	SetIconState(stored_mmi.icon_state)

	stored_mmi.brainmob.languages = owner.languages

	if(owner && owner.stat == DEAD)
		owner.set_stat(CONSCIOUS)
		owner.visible_message("<span class='danger'>\The [owner] twitches visibly!</span>")

/obj/item/organ/internal/mmi_holder/removed(var/mob/living/user)

	if(stored_mmi)
		stored_mmi.loc = get_turf(src)
		if(owner.mind)
			owner.mind.transfer_to(stored_mmi.brainmob)
	..()

	var/mob/living/holder_mob = loc
	if(istype(holder_mob))
		holder_mob.drop_from_inventory(src)

	if(!(QDELETED(src)))
		qdel(src)

/obj/item/organ/internal/mmi_holder/emp_act(severity)
	..()
	owner?.adjustToxLoss(rand(6/severity, 12/severity))

/obj/item/organ/internal/mmi_holder/posibrain
	name = "positronic brain interface"
	brain_type = /obj/item/device/mmi/digital/posibrain

/obj/item/organ/internal/mmi_holder/posibrain/update_from_mmi()
	..()
	stored_mmi.SetIconState("posibrain-occupied")
	SetIconState(stored_mmi.icon_state)

	stored_mmi.brainmob.languages = owner.languages
