"use client";
import { useSession, signIn, signOut } from "next-auth/react";

export default function AuthButton() {
  const { data: session } = useSession();

  return (
    <div style={{ marginBottom: "0.5rem" }}>
      {session ? (
        <>
          {/* <p>Signed in as {session.user.email}</p> */}
          <button id="google-calendar-confirm" onClick={() => signOut()}>
            Sign out
          </button>
        </>
      ) : (
        <button id="google-calendar-confirm" onClick={() => signIn("google")}>
          Sign in with Google
        </button>
      )}
    </div>
  );
}
