"use client";

import { useRef, useState } from "react";

export function useAudioRecorder() {
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const [isRecording, setIsRecording] = useState(false);
  const supported =
    typeof window !== "undefined" &&
    typeof MediaRecorder !== "undefined" &&
    !!navigator.mediaDevices?.getUserMedia;

  async function startRecording() {
    if (!supported) {
      throw new Error("Audio recording is not supported in this browser.");
    }

    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    const recorder = new MediaRecorder(stream);
    streamRef.current = stream;
    mediaRecorderRef.current = recorder;
    chunksRef.current = [];
    recorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        chunksRef.current.push(event.data);
      }
    };
    recorder.start();
    setIsRecording(true);
  }

  function stopRecording() {
    return new Promise<Blob>((resolve, reject) => {
      const recorder = mediaRecorderRef.current;
      if (!recorder) {
        reject(new Error("No active recording."));
        return;
      }

      recorder.onstop = () => {
        setIsRecording(false);
        streamRef.current?.getTracks().forEach((track) => track.stop());
        mediaRecorderRef.current = null;
        streamRef.current = null;
        resolve(new Blob(chunksRef.current, { type: recorder.mimeType }));
      };
      recorder.stop();
    });
  }

  return { isRecording, startRecording, stopRecording, supported };
}
