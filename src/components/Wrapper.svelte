<main style="min-height: 100lvh; padding:10px">

    <div class="flex mb-2 gap-2 items-center">
        <div class="w-max-20">
            <Select size="sm" class="py-1 text-sm" style="height:34px" items={zones} on:change={handleZoneChange}  bind:value={zoneSwitch.current}/></div>
        <div class="w-max-20">
            <Input size="sm" id="minDate" on:change={handleDateChange} bind:value={minDate} name="minDate" required type="date"/>
        </div>
        <div class="w-max-20">
            <Button size="xs" outline>Сохранить</Button>
        </div>
        <div class="ml-4 text-xs text-gray-500">
            hint: для выбора нескольких слотов — выделите область удерживайте кнопку мыши
        </div>
    </div>
    {#if selectedZone}
        <div class="flex mb-2 gap-2">
            {#each selectedZone.types as type}
                <Badge color="dark" border style="background-color: {type.color}; color: #fff">{type.label}</Badge>
            {/each}
        </div>
        <div class="flex  mt-2 gap-2 items-center" style="zoom: 0.8;">

            {#each selectedZone.tags as tag}
                <a href={undefined} on:click={()=>handleTagClick(tag)} class="cursor-pointer">
                    <Badge color="{selectedTag===tag?'red':'dark'}" border class="text-xs">{tag.name}</Badge>
                </a>
            {/each}
        </div>

        {#key selectedZone.value + minDate + JSON.stringify(selectedTag)}
            <CanvasTimeline zone={selectedZone} fromDate={minDate} selectedTag={selectedTag} bind:reset={resetSelection} />
        {/key}


        <Modal bind:open={defaultModal} size="xs" autoclose>
            <div class="text-center">
<!--                <ExclamationCircleOutline class="mx-auto mb-4 text-gray-400 w-12 h-12 dark:text-gray-200" />-->

                <h3 class="mb-5 text-lg font-normal text-gray-500 dark:text-gray-400">При смене площадки, все несохраненные данные будут удалены</h3>
                <Button color="red" class="me-2" on:click={handleChangeZoneAccept}>Да, хорошо</Button>
                <Button color="alternative">Ой, нет, отмена!</Button>
            </div>
        </Modal>


    {/if}
</main>

<script>
  import {Badge, Button, Input, Modal, Select} from "flowbite-svelte";
  import {apiService} from "../lib/api.js";
  import {getZones} from "../data.js";
  import CanvasTimeline from "./CanvasTimeline.svelte";
  import {ExclamationCircleOutline} from "flowbite-svelte-icons";
  import {slotsInfo} from "../lib/MainStore.js";

  let defaultModal = false

  let selectedTag = undefined
  let resetSelection;

  function handleTagClick(tag) {
    if (selectedTag === tag) {
      selectedTag = undefined
    } else {
      selectedTag = tag
    }
    // resetSelection()

  }
  let zoneSwitch = {
    previous: 1,
    current: 1,
    next: undefined,
  }

  function handleChangeZoneAccept() {
    defaultModal = false
    zoneSwitch.previous = zoneSwitch.next
    zoneSwitch.current = zoneSwitch.next
    selectedZoneId = zoneSwitch.next
    $slotsInfo = {}
  }

  function handleZoneChange(e) {
    defaultModal = true
    zoneSwitch.next = zoneSwitch.current
    zoneSwitch.current = zoneSwitch.previous


  }

  function handleDateChange(e) {
    minDate = e.target.value
  }

  let minDate = new Date().toISOString().split('T')[0]

  let zones = []
  let selectedZoneId = 1
  $: selectedZone = zones.find(a => a.value === selectedZoneId)
  getZones().then(a => zones = a)

</script>