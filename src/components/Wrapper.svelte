<main style="min-height: 100lvh; padding:10px">
    <Toast class="absolute top-0 left-0" color="green" dismissable={true} transition={slide} bind:open={savedToast}>
        <svelte:fragment slot="icon">✓</svelte:fragment>
        Успешно сохранено
    </Toast>


    <div class="flex mb-2 gap-2 items-center">
        <div class="w-max-20">
            <Select size="sm" class="py-1 text-sm" style="height:34px" items={$zones.map(a=>({value:a.id, name:a.label}))} on:change={handleZoneChange} bind:value={zoneSwitch.current}/>
        </div>
        <div class="w-max-20">
            <Input size="sm" id="minDate" on:change={handleDateChange} bind:value={minDate} name="minDate" required type="date"/>
        </div>
        <div class="w-max-20">
            <Button size="xs" disabled={!$hasChanges} outline on:click={handleSave}>Сохранить</Button>
        </div>
        <div class="w-max-20">
            <Button size="xs" outline on:click={()=>exportModal=true}>Экспорт</Button>
        </div>
        <div class="ml-4 text-xs text-gray-500">
            hint: для выбора нескольких слотов — выделите область удерживайте кнопку мыши
        </div>
        <div class="ml-4 text-xs text-gray-500 flex flex-grow justify-end">
            <Button size="xs" color="dark" outline on:click={handleShowSettingsClick}>Настройки</Button>
        </div>
    </div>
    {#if selectedZone}
        <div class="flex mb-2 gap-2">
            {#each selectedZone.types.filter(t => !t.label.startsWith('_')) as type}
                <Badge color="dark" border style="background-color: {type.color}; color: #fff">{type.label}</Badge>
            {/each}
        </div>
        <div class="flex  mt-2 gap-2 items-center" style="zoom: 0.8;">

            {#each selectedZone.tags.filter(t => !t.label.startsWith('_')) as tag}
                <a href={undefined} on:click={()=>handleTagClick(tag)} class="cursor-pointer">
                    <Badge color={selectedTag===tag?'red':'dark'} border class="text-xs">{tag.label}</Badge>
                </a>
            {/each}
        </div>

        {#if $settings.daysCount}
            {#key renderKey}
                <CanvasTimeline zone={selectedZone} fromDate={minDate} selectedTag={selectedTag} daysCount={$settings.daysCount} slotSizeX={$settings.slotSizeX} slotSizeY={$settings.slotSizeY} bind:reset={resetSelection}/>
            {/key}
        {/if}


        <Modal bind:open={defaultModal} size="xs" autoclose>
            <div class="text-center">
                <!--                <ExclamationCircleOutline class="mx-auto mb-4 text-gray-400 w-12 h-12 dark:text-gray-200" />-->

                <h3 class="mb-5 text-lg font-normal text-gray-500 dark:text-gray-400">При смене площадки, все
                    несохраненные данные будут удалены</h3>
                <Button color="red" class="me-2" on:click={handleChangeZoneAccept}>Да, хорошо</Button>
                <Button color="alternative">Ой, нет, отмена!</Button>
            </div>
        </Modal>

        <Modal bind:open={settingsModal} size="md">
            <SettingsMenu/>
        </Modal>

        <ExportModal bind:open={exportModal} zone={selectedZone} on:done={()=>{}}/>

    {/if}


</main>

<script>
  import {Badge, Button, Input, Modal, Select, Toast} from "flowbite-svelte";
  import CanvasTimeline from "./CanvasTimeline.svelte";
  import {hasChanges, slotsInfo, zones, settings} from "../lib/MainStore.js";
  import {apiService} from "../lib/api.js";
  import {slide} from "svelte/transition";
  import ExportModal from "./ExportModal.svelte";
  import SettingsMenu from "./SettingsMenu.svelte";


  $: renderKey = JSON.stringify(selectedZone) + minDate + JSON.stringify(selectedTag) + JSON.stringify(settings)


  let defaultModal = false
  let settingsModal = false
  let exportModal = false

  let selectedTag = undefined
  let resetSelection;
  let savedToast = false


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
    $hasChanges = false

    if (selectedZoneId === 0) {
      settingsModal = true
    }
  }

  function handleZoneChange(e) {
    zoneSwitch.next = zoneSwitch.current
    zoneSwitch.current = zoneSwitch.previous

    if ($hasChanges) {
      defaultModal = true
    } else {
      handleChangeZoneAccept()
    }
  }


  function handleDateChange(e) {
    minDate = e.target.value
  }

  let minDate = new Date().toISOString().split('T')[0]


  let selectedZoneId = undefined
  $: selectedZone = $zones.find(a => a.id === selectedZoneId)

  function fetchZones() {
    return apiService.getZones().then(a => {

    })
  }

  fetchZones().then(() => {
    if ($zones.length === 0) return;
    selectedZoneId = $zones[0].id
  })

  // getZones().then(a => zones = a)

  function handleSave() {
    apiService.saveSlots(selectedZone.id, Object.values($slotsInfo)).then(a => {
      $hasChanges = false
      savedToast = true
      setTimeout(() => {
        savedToast = false
      }, 2000)
    })
  }

  function handleShowSettingsClick() {
    settingsModal = true
  }

  function handleSettingsChanged(e) {
    const zoneId = e.detail.id
    fetchZones().then(() => {
      zoneSwitch.next = zoneId
      handleChangeZoneAccept()
    })

    settingsModal = false
  }

</script>