<div>
    <Modal autoclose bind:open={open} size="xs">
        <div class="flex flex-col items-center justify-center gap-4">

            <div class="flex flex-row items-center justify-center gap-2">
                <div class="w-max-20">
                    <Input bind:value={minDate} id="minDate" name="minDate" required size="md" type="date"/>
                </div>
                по
                <div class="w-max-20">
                    <Input bind:value={maxDate} id="minDate" name="maxDate" required size="md" type="date"/>
                </div>
            </div>

            <div class="flex flex-row items-center justify-center gap-2">
                <Button class="me-2" color="red" on:click={()=>handleExportClick('json')}> JSON</Button>
            </div>

        </div>
    </Modal>

</div>
<script>
  import {Button, Input, Modal, Select, Toast} from "flowbite-svelte";
  import {apiService} from "../lib/api.js";
  import saveAs from 'file-saver';

  export let open = false
  export let zone


  let minDate = new Date().toISOString().split('T')[0]
  let maxDate = new Date(new Date(minDate).getTime() + (35 * 24 * 60 * 60 * 1000)).toISOString().split('T')[0]


  function handleExportClick(exportType) {

    if (exportType === 'json') {

      const fileName = `export_${zone.label}_${minDate}_${maxDate}.json`

      apiService.export(zone.id, minDate, maxDate).then(a => {
        saveAs(new Blob([JSON.stringify(a, null, 2)]), fileName)
      })
    }

  }


</script>