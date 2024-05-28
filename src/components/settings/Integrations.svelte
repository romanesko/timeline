<div class="flex flex-col">
    <div class="m-4 mt-2 flex flex-row items-center gap-4">
        <div class="w-max-20">
            <Select bind:value={zoneId} class="py-1 text-sm" items={$zones.map(a=>({value:a.id, name:a.label}))} on:change={handleOptsChange} size="sm" style="height:34px"/>
        </div>
        <div class="w-max-20">
            <Input bind:value={minDate} id="minDate" name="minDate" on:change={handleOptsChange} required size="sm" type="date"/>
        </div>
        по
        <div class="w-max-20">
            <Input bind:value={maxDate} id="minDate" name="maxDate" on:change={handleOptsChange} required size="sm" type="date"/>
        </div>
    </div>

    <div class="mx-4">
        <div class="flex flex-col items-center justify-center gap-4">

            <div class="flex flex-col">
                {#each instructionCode as code}
                    {code[0]}
                    <code class="text-xs border border-gray-300 p-2 my-2 rounded-md" style="user-select: all;">
                        <pre style=" white-space: pre-wrap;   ">{code[1]}</pre>
                    </code>
                {/each}
            </div>
        </div>
    </div>
</div>

<script>
  import {Input, Select} from "flowbite-svelte";
  import {apiService} from "../../lib/api.js";
  import {hasChanges, slotsInfo, zones} from "../../lib/MainStore.js";

  let zoneId = $zones[0]?.id
  let minDate = new Date().toISOString().split('T')[0]
  let maxDate = new Date(new Date(minDate).getTime() + (35 * 24 * 60 * 60 * 1000)).toISOString().split('T')[0]
  let instructionCode = []

  function handleOptsChange() {
    showInstruction()
  }

  let systemToken = ''
  apiService.getAdminKeys().then(tokens => {
    systemToken = tokens[0].token
    showInstruction()
  })

  async function showInstruction() {
    instructionCode = []


    let params = {
      "zone": zoneId,
      "from": minDate,
      "to": maxDate,
      "token": systemToken
    }


    instructionCode = [
      ['CURL', `curl ${apiService.api.host}/export -X POST -H "Content-Type: application/json" -d ${JSON.stringify(params)}`],
      ['JS', `function getTimelineData(zone, from, to, token){ return fetch('${apiService.api.host}/export', {method: 'POST', headers: {Authorization: "Token " + token}, body: JSON.stringify({zone, from, to})}).then(a => a.json())};

getTimelineData(${zoneId}, '${minDate}', '${maxDate}', '${systemToken}').then(a => {
  console.log(a)
})
`]
    ]
    // instructionCode += `FETCH:`
    // instructionCode += `\n\n`


    ///await fetch(`${this.host}${path}`, {method: 'POST', headers, body: JSON.stringify(data)})

  }

</script>