import React, {useState} from 'react';
import API from '../api';

export default function Signup(){
  const [name,setName]=useState('');
  const [email,setEmail]=useState('');
  const [pw,setPw]=useState('');
  const submit=async()=>{
    const r=await API.post('/api/auth/register',{name,email,password:pw}).catch(e=>alert('signup failed'));
    if(r?.data?.token){
      localStorage.setItem('token', r.data.token);
      alert('registered');
    }
  }
  return (<div style={{padding:20}}>
    <h3>Signup</h3>
    <input placeholder="name" value={name} onChange={e=>setName(e.target.value)} /> <br/>
    <input placeholder="email" value={email} onChange={e=>setEmail(e.target.value)} /> <br/>
    <input placeholder="password" type="password" value={pw} onChange={e=>setPw(e.target.value)} /> <br/>
    <button onClick={submit}>Signup</button>
  </div>);
}
