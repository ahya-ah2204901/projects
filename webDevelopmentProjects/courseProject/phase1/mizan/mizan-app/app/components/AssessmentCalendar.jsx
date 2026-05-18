"use client";
import React, { useEffect, useState } from "react";
import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import Assessment from "../model/Assessment";
import { useSession } from "next-auth/react";
import AuthButton from "./AuthButton";

export default function AssessmentCalendar() {
  const [events, setEvents] = useState([]);
  const { data: session } = useSession();

  useEffect(() => {
    const fetchingAssess = async () => {
      try {
        const user = JSON.parse(localStorage.getItem("user"));
        const currentSem = JSON.parse(localStorage.getItem("currentSem"));
        const response = await fetch(
          `/api/semesters/${currentSem}/courses/assessments?userId=${user.id}`,
          {
            method: "GET",
            headers: {
              "Content-Type": "application/json",
            },
          }
        );

        const data = await response.json();
        if (!data.error) {
          const assessObjs = await Promise.all(
            data.map(async (assessData) => {
              const assess = new Assessment(assessData);
              return assess;
            })
          );

          const calendarEvents = assessObjs.map((a) => ({
            title: a.title,
            date: a.dueDate,
            allDay: true,
          }));

          setEvents(calendarEvents);
        } else {
          console.error(data.error);
        }
      } catch (err) {
        console.error(err);
      }
    };

    fetchingAssess();
  }, []);

  async function syncToGoogleCalendar() {
    if (!session?.accessToken) {
      alert("Please sign in with Google first.");
      return;
    }

    try {
      for (const event of events) {
        const startDate = new Date(event.date);
        const startDateFormatted = startDate.toISOString().split("T")[0];

        const endDate = new Date(startDate.getTime() + 86400000);
        const endDateFormatted = endDate.toISOString().split("T")[0];

        const response = await fetch("/api/sync-calendar", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            summary: event.title,
            start: { date: startDateFormatted },
            end: { date: endDateFormatted },
          }),
        });

        const resultText = await response.text();

        try {
          const result = JSON.parse(resultText);
          if (response.ok) {
            console.log("Event created:", result);
          } else {
            console.error("Error creating event:", result);
          }
        } catch (err) {
          console.error("Failed to parse error response:", resultText);
        }
      }

      alert("All events synced to Google Calendar!");
    } catch (err) {
      console.error(err);
      alert("Something went wrong during syncing.");
    }
  }

  return (
    <>
      <div className="google-auth-container">
        <AuthButton />
      </div>
      <div className="google-div">
        <button
          id="google-calendar-sync"
          onClick={syncToGoogleCalendar}
          className="btn mt-2"
        >
          <i className="bi bi-google"></i>
          <p>Sync All Events to Google Calendar</p>
        </button>
      </div>
      <div className="calendar-container p-4">
        <FullCalendar
          plugins={[dayGridPlugin]}
          initialView="dayGridMonth"
          events={events}
          height="auto"
          headerToolbar={{
            left: "prev,next today",
            center: "title",
            right: "",
          }}
        />
      </div>
    </>
  );
}