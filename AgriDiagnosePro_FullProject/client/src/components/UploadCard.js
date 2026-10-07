import React, {useState} from 'react';
import API from '../api';

export default function UploadCard(){
  const [file,setFile]=useState(null);
  const [lat,setLat]=useState('');
  const [lon,setLon]=useState('');
  const pickGPS=()=>{
    if(navigator.geolocation){
      navigator.geolocation.getCurrentPosition(p=>{
        setLat(p.coords.latitude); setLon(p.coords.longitude);
      });
    } else alert('Geolocation not available');
  }
  const submit=async()=>{
    if(!file) return alert('choose file');
    const fd = new FormData();
    fd.append('image', file);
    fd.append('latitude', lat);
    fd.append('longitude', lon);
    fd.append('timestamp', new Date().toISOString());
    const token = localStorage.getItem('token');
    const r = await API.post('/api/diagnosis', fd, { headers: { Authorization: token ? `Bearer ${token}` : '' } }).catch(e=>{ alert('upload failed'); });
    if(r?.data) alert('Result: '+ JSON.stringify(r.data.result));
  }
  return (<div>
    <h4>Upload</h4>
    <input type="file" accept="image/*" onChange={e=>setFile(e.target.files[0])} /><br/>
    <button onClick={pickGPS}>Capture GPS</button><br/>
    <input placeholder="lat" value={lat} onChange={e=>setLat(e.target.value)} />
    <input placeholder="lon" value={lon} onChange={e=>setLon(e.target.value)} />
    <br/>
    <button onClick={submit}>Submit for Diagnosis</button>
  </div>);
}
