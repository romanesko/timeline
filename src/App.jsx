import { createResource, createSignal } from 'solid-js'

import './App.css'
import './slot.css'
import { AuthScreen } from './Auth'
import {getCookie, setCookie, api} from './common'


const hours = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
const monthes = ['янв', 'фев', 'мар','апр','мая','июн','июл','авг','сен','окт','ноя','дек']
const daysOfWeek = ['вс', 'пн','вт','ср','чт','пт','сб']


function formatTime(date) {
  let hours = date.getHours();
  let minutes = date.getMinutes();
  // hours = (hours < 10) ? "0" + hours : hours;
  minutes = (minutes < 10) ? "0" + minutes : minutes;
  return [hours, minutes]
}

function fetchData() {
  return api.get('slots/get')
}

function setState(date,slot){
    api.post('slots/state/set',{date, num: slot.num, state:slot.state}).catch(e=>alert(e.message))
}

function classByState(state) {
  switch (state) {
    case 'FREE': return 'free'
    case 'FREE_RIDE': return 'free-ride'
    case 'BOOKED': return 'booked'
    case 'TECH': return 'tech'
  }

}


function App() {


  const token = getCookie('token')

  if(!token)
  return <AuthScreen/>



  const [count, setCount] = createSignal(0)

  const [data, { mutate }] = createResource(fetchData)

  const [selectedState, setSelectedState] = createSignal()

  function handleSelectState(state) {
    setSelectedState(state)
  }



  function renderSlots(date, slots) {

    return slots.map(a => {
      let cls = "slot " + classByState(a.state)
      if (a.hour % 2 == 0) { cls += ' even' }
      if (a.min == 0) { cls += ' start' }

      return <div class={cls} onClick={() => {

        if (!selectedState()) { return alert('Сперва выберите статус') }

        if (a.state == selectedState()) {
          a.state = 'FREE'
        } else {
          a.state = selectedState()
        }

        setState(date,a)
        mutate(Object.assign([], data()))
      }}>
        <div class="item">{a.min}</div>
      </div>
    })
  }

  function dateFormat(date){
    date = new Date(date)
    
    return daysOfWeek[date.getDay()] + ' ' + date.getDate() + ' ' + monthes[date.getMonth()]
  }

  function renderLine(row) {
    return <div class="day">
      <div class="date">{dateFormat(row.date)}</div>
      <div class="slots">
        {renderSlots(row.date, row.slots)}
      </div>
    </div>
  }

  function renderStateSelectButton(state, title) {
    let cls = classByState(state)
    cls += ' legend'
    if (selectedState() == state) {
      cls += ' selected'
    }
    return <div class={cls} onClick={() => handleSelectState(state)}>{title}</div>
  }



  return <>
  <Show when={data()} fallback={<div>Loading…</div>}>
    <div style="display:flex; margin-bottom:10px; justify-content:center; gap:4px;">
      {renderStateSelectButton('FREE', 'свободно')}
      {renderStateSelectButton('FREE_RIDE', 'свободное катание')}
      {renderStateSelectButton('BOOKED', 'бронь')}
      {renderStateSelectButton('TECH', 'технический перерыв')}
    </div>
    <div class="day">
      <div class="date"></div>
      <div style=" display:flex; ">
        {hours.map(a => <div style="border-top:1px solid gray; font-size:0.9em; border-left:2px solid black; width:78px;">{a}</div>)}
      </div>
    </div>
    <div class="slots-pane">
        {data().map(row => renderLine(row))}
    </div>
    </Show>
  </>
}

export default App
