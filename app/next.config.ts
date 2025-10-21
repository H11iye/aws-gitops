import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  // cast experimental to any to allow options not present in the installed Next.js types
  experimental: { appDir: true } as any,

};

export default nextConfig;
