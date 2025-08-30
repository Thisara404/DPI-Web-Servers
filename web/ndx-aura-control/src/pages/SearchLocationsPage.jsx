import React, { useState } from "react";
import ndxApi from "@/api/ndxApi";

export default function SearchLocationsPage() {
  const [q, setQ] = useState("");
  const [results, setResults] = useState([]);

  async function search(e) {
    e.preventDefault();
    if (!q) return;
    const res = await ndxApi.get("/routes/search-locations", { params: { query: q } });
    setResults(res.data?.data || res.data || []);
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Search Locations</h1>
      <form onSubmit={search} className="mt-4">
        <input value={q} onChange={(e)=>setQ(e.target.value)} placeholder="Search..." className="input" />
        <button className="btn ml-2">Search</button>
      </form>
      <ul className="mt-4">
        {results.map((r,i) => <li key={i}>{r.name || r.display_name}</li>)}
      </ul>
    </div>
  );
}