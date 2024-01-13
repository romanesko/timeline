import { createSignal } from "solid-js"
import {api} from './common'

const styles = {
    input: "width:200px; font-size:18px; border:1px solid #ddd; border-radius:4px; padding:10px",
    button: "width:200px",
    error: "margin:4px; font-size:16px; padding: 2px 12px; background:#FFdddd; color:red; border:1px dotted red; border-radius:0px"
} 

export function AuthScreen(){

    const [login,setLogin] = createSignal()
    const [pass, setPass] = createSignal()
    const [err,setErr] = createSignal()

    async function doLogin(){
        try{
            const response = await api.login(login(), pass())        
            document.location.reload()
        } catch(e){
            setErr(e.message)
        }
    }


    return <div style="display:flex; flex-direction: column; gap:8px; align-items:center">
        <Show when={err()}>
            <div style={styles.error}>{err()}</div>
        </Show>
        
        <input type="text" style={styles.input} placeholder="login" onInput={e=>setLogin(e.target.value)}/>
        <input type="password" style={styles.input}  placeholder="password" onInput={e=>setPass(e.target.value)}/>
        <button style={styles.button} onClick={()=>doLogin()}>LOGIN</button>

    </div>
}