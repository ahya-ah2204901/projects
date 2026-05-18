"use client";
import React from "react";
import { SessionProvider } from "next-auth/react";
import AssessmentCalendar from "@/app/components/AssessmentCalendar";

export default function CalendarsPage() {
  return (
    <main id="calendar-main">
      <SessionProvider>
        <AssessmentCalendar />
      </SessionProvider>
    </main>
  );
}
