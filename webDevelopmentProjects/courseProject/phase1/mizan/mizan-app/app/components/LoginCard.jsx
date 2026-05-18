"use client";
import { useRouter } from "next/navigation";
import React, { useState } from "react";
import Semester from "../model/Semester";

export default function LoginCard() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const router = useRouter();

  const handleLogin = async (e) => {
    e.preventDefault();

    try {
      const response = await fetch("/api/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
      });

      const data = await response.json();

      if (!data.error) {
        console.log("Logged in user:", data.user);
        localStorage.user = JSON.stringify(data.user);
        const currSem = Semester.getCurrentSem()
        localStorage.setItem("currentSem", JSON.stringify(currSem.id));
        localStorage.setItem("currentSemLabel", JSON.stringify(currSem.label));
        console.log(localStorage.user);

        router.push("/home");
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError(null);
      setError("Something went wrong. Please try again.");
      console.error(err);
    }
  };

  return (
    <main id="loginmain">
      <div className="login-card">
        <div className="login-title">
          <h1>Mizan</h1>
          <p>Your Assessment Tracker Buddy</p>
        </div>
        <form onSubmit={handleLogin}>
          <label htmlFor="email">Email</label>
          <input
            type="email"
            id="email"
            placeholder="you@example.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <label htmlFor="password">Password</label>
          <input
            type="password"
            id="password"
            placeholder="••••••••"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          <button id="login-btn" type="submit">
            Log In
          </button>
        </form>
        {error && <div className="errormessage">{error}</div>}
        <div className="signup">
          Don't have an account? <a href="#">Sign Up</a>
        </div>
      </div>
    </main>
  );
}
