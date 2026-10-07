import React, {useState} from 'react';
import API from '../api';

export default function Login(){
  const [email,setEmail]=useState('');
  const [pw,setPw]=useState('');
  const submit=async()=>{
    const r=await API.post('/api/auth/login',{email,password:pw}).catch(e=>alert('login failed'));
    if(r?.data?.token){
      localStorage.setItem('token', r.data.token);
      alert('logged in');
    }
  }
  return (<div style={{padding:20}}>
    <h3>Login</h3>
    <input placeholder="email" value={email} onChange={e=>setEmail(e.target.value)} /> <br/>
    <input placeholder="password" type="password" value={pw} onChange={e=>setPw(e.target.value)} /> <br/>
    <button onClick={submit}>Login</button>
  </div>);
}
