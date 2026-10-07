import React, {useEffect, useState} from 'react';
import API from '../api';

export default function History(){
  const [items,setItems]=useState([]);
  useEffect(()=>{API.get('/api/diagnosis/history').then(r=>setItems(r.data.items)).catch(()=>{});},[]);
  return (<div style={{padding:20}}>
    <h3>History</h3>
    {items.map(it=> (
      <div key={it._id} style={{border:'1px solid #ccc', padding:10, margin:10}}>
        <div>Disease: {it.disease} ({it.confidence})</div>
        <div>Date: {new Date(it.timestamp).toLocaleString()}</div>
        <div>Location: {it.latitude},{it.longitude}</div>
        <div>Image: <img src={window._env?.API_BASE ? window._env.API_BASE + it.imageURL : it.imageURL} alt="img" style={{maxWidth:200}}/></div>
      </div>
    ))}
  </div>);
}
