<div class="flex flex-col gap-2 items-center mt-4">

    <div class="text-center text-gray-500 text-xs mb-4">
        <p>Персональные настройки пользователя (сохраняются только на этом компьютере)</p>
    </div>

    <div class="flex flex-row gap-2">
        <div class="setting-label">Количество дней:</div>
        <div class="w-max-20">
            <Input bind:value={daysCount} id="daysCount" name="daysCount" required size="sm" type="number"/>
        </div>
    </div>

    <div class="flex flex-row gap-2">
        <div class="setting-label">Ширина слота:</div>
        <div class="w-max-20">
            <Input bind:value={slotSizeX} id="minDate" name="minDate" required size="sm" type="number"/>
        </div>
    </div>
    <div class="flex flex-row gap-2">
        <div class="setting-label">Высота слота:</div>
        <div class="w-max-20">
            <Input bind:value={slotSizeY} id="minDate" name="minDate" required size="sm" type="number"/>
        </div>
    </div>
    <div class="mt-4">
        <Button color="primary" on:click={handleSave}>Сохранить</Button>
    </div>


</div>

<script>
  // import {minDate, daysCount} from "../../lib/MainStore.js";
  import {Button, Input} from "flowbite-svelte";
  import {settings} from "../../lib/MainStore.js";


  let daysCount = $settings['daysCount']
  let slotSizeX = $settings['slotSizeX']
  let slotSizeY = $settings['slotSizeY']


  function handleSave() {

    if (isNaN(+daysCount)) {
      alert('Количество дней должно быть числом')
      return
    }

    if (isNaN(+slotSizeX)) {
      alert('Ширина слота должна быть числом')
      return
    }

    if (isNaN(+slotSizeY)) {
      alert('Высота слота должна быть числом')
      return
    }

    settings.update(a => {
      a['daysCount'] = +daysCount
      a['slotSizeX'] = +slotSizeX
      a['slotSizeY'] = +slotSizeY
      return a
    })
  }

</script>

<style>
    .setting-label {
        min-width: 150px;
    }
</style>

