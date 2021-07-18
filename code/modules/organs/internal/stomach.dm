/obj/item/organ/internal/stomach
	name = "stomach"
	icon_state = "stomach"
	organ_efficiency = list(OP_STOMACH = 100)
	parent_organ_base = BP_CHEST
	price_tag = 700
	blood_req = 5
	max_blood_storage = 25
	oxygen_req = 5

/obj/item/organ/internal/stomach/machine //O_CYCLER
	name = "reagent cycler"
	icon_state = "cycler"
	nature = MODIFICATION_SILICON

/*
/obj/item/organ/internal/stomach/machine/handle_organ_proc_special()
	..()
	if(owner && owner.stat != DEAD)
		owner.bodytemperature += round(owner.robobody_count * 0.25, 0.1)

		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner

			if(H.ingested?.total_volume && H.bloodstr)
				H.ingested.trans_to_holder(H.bloodstr, rand(2,5))

	return
*/
