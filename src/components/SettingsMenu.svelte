<div style="min-height:50lvh">
    <Tabs contentClass="py-2  mt-2" tabStyle="underline">
        <TabItem open title="Зоны">
            <div class="flex flex-row">
                <div>
                    <Listgroup active class="w-48" items={zonesButtons} let:item on:click={(e) => handleZoneClick(e.detail)}>
                        {item.name}
                    </Listgroup>
                    <Button class="my-4 w-full " color="primary" on:click={()=>handleZoneClick({id:0, types:[], tags:[]})} outline size="xs">
                        Добавить новую зону
                    </Button>

                </div>
                {#if selectedZone}
                    {#key selectedZone.id}
                        <Settings zone={selectedZone} on:done={handleSettingsChanged}/>
                    {/key}
                {/if}
            </div>
        </TabItem>
        <TabItem title="Интеграции">
            <Integrations/>
        </TabItem>
        <TabItem title="Настройки интерфейса">
            <Interface/>
        </TabItem>
    </Tabs>

</div>
<script>
  import Settings from "./Settings.svelte";
  import {zones} from "../lib/MainStore.js";

  import {Button, Listgroup, TabItem, Tabs} from "flowbite-svelte";
  import {apiService} from "../lib/api.js";
  import Integrations from "./settings/Integrations.svelte";
  import Interface from "./settings/Interface.svelte";

  let selectedZone = $zones[0]

  $: zonesButtons = $zones.map(z => ({name: z.label, id: z.id, current: selectedZone?.id === z.id}));

  function handleZoneClick(zone) {
    selectedZone = $zones.find(z => z.id === zone.id);
  }

  function handleSettingsChanged(event) {
    apiService.getZones().then(() => {
      selectedZone = $zones.find(z => z.id === event.detail.id);
    })

  }


</script>
